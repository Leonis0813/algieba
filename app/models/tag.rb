class Tag < ApplicationRecord
  has_many :payment_tags, dependent: :destroy
  has_many :payments, through: :payment_tags

  validates :tag_id, :name,
            presence: {message: 'absent'}
  validates :tag_id,
            format: {with: /\A[0-9a-f]{32}\z/, message: 'invalid'},
            allow_nil: true
  validates :name,
            length: {maximum: 10, message: 'invalid'},
            allow_nil: true
end
