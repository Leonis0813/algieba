class PaymentTag < ApplicationRecord
  belongs_to :payment
  belongs_to :tag
end
