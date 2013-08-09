class Deposit < AccountOperation 
  include ActionView::Helpers::NumberHelper
  include ActiveRecord::Transitions
  
  DEPOSIT_COMMISSION_RATE = BigDecimal("0.01")
  
  attr_accessible :bank_account_id, :bank_account_attributes

  belongs_to :account
  
  #accepts_nested_attributes_for :bank_account
  
  #before_validation :check_bank_account_id

  validates :currency,
    :inclusion => { :in => ["BRL"] }
  
  validates :amount,
    :numericality => true,
    :minimal_amount => true
    #:negative => false
    
  state_machine do
    state :pending
    state :processed

    event :process do
      transitions :to => :processed,
        :from => :pending
    end
  end
  
  def self.from_params(params)
    deposit = class_for_transfer(params[:currency]).new(params)
   
    if deposit.amount
      deposit.amount = deposit.amount.abs 
    end
    
    deposit
  end
  
  def self.class_for_transfer(currency)
    currency = currency.to_s.downcase.to_sym
    self
  end
  
  def execute
    
    raise 'executing'
    
  end

  def check_bank_account_id
    if bank_account_id && account.bank_accounts.find(bank_account_id).blank?
      raise "Someone is trying to pull something fishy off"
    end
  end
  
  def deposit_after_fee
    
    if self.amount > 0
      # fee already deducted
      number_to_currency(self.amount , unit: "", separator: ".", delimiter: ',', precision: 3)
    end
    
  end
  
  def deposit_before_fee
    rounded = '%.0f' % (amount * (1 + DEPOSIT_COMMISSION_RATE))
    number_to_currency(rounded , unit: "", separator: ".", delimiter: ',', precision: 3)
  end
  
  def withdrawal_after_fee
  end
  
end
