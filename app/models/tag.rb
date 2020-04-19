class Tag < ApplicationRecord
  has_many :payment_tags, dependent: :destroy
  has_many :payments, through: :payment_tags

  validates :tag_id, :name,
            presence: {message: 'absent'}
  validates :tag_id,
            format: {with: ID_FORMAT, message: 'invalid'},
            allow_nil: true
  validates :name,
            length: {maximum: 10, message: 'invalid'},
            allow_nil: true

  scope :name_include, ->(name) { where('name REGEXP ?', ".*#{name}.*") }

  after_initialize if: :new_record? do |tag|
    tag.tag_id = SecureRandom.hex
  end
end
