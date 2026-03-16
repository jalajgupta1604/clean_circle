class WalletTransaction < ApplicationRecord
  belongs_to :wallet

  enum :transaction_type, { credit: 0, debit: 1 }

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :transaction_type, presence: true
end
