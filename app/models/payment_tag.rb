class PaymentTag < ApplicationRecord
  belongs_to :payment
  belongs_to :tag

  validates :payment_id,
            uniqueness: {scope: :tag_id, message: MESSAGE_SAME_VALUE}
end
