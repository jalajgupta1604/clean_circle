class Wallet < ApplicationRecord
  belongs_to :user
  has_many :wallet_transactions, dependent: :destroy

  validates :balance, numericality: { greater_than_or_equal_to: 0 }

  def credit!(amount, description: "Wallet recharge", reference_id: nil)
    transaction do
      wallet_transactions.create!(
        amount: amount,
        transaction_type: :credit,
        description: description,
        reference_id: reference_id
      )
      increment!(:balance, amount)
    end
  end

  def debit!(amount, description: "Pickup charge", reference_id: nil)
    raise InsufficientBalanceError, "Insufficient wallet balance" if balance < amount

    transaction do
      wallet_transactions.create!(
        amount: amount,
        transaction_type: :debit,
        description: description,
        reference_id: reference_id
      )
      decrement!(:balance, amount)
    end
  end

  def sufficient_balance?(amount)
    balance >= amount
  end

  class InsufficientBalanceError < StandardError; end
end
