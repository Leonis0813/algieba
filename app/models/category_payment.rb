class CategoryPayment < ApplicationRecord
  belongs_to :category
  belongs_to :payment

  validates :category_id,
            uniqueness: {scope: :payment_id, message: MESSAGE_SAME_VALUE}
end
