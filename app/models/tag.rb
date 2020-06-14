class Tag < ApplicationRecord
  has_many :payment_tags, dependent: :destroy
  has_many :payments, through: :payment_tags

  validates :tag_id, :name,
            presence: {message: MESSAGE_ABSENT}
  validates :tag_id,
            format: {with: ID_FORMAT, message: MESSAGE_INVALID},
            uniqueness: {message: MESSAGE_DUPLICATED},
            allow_nil: true
  validates :name,
            length: {maximum: 10, message: MESSAGE_INVALID},
            uniqueness: {message: MESSAGE_DUPLICATED}

  scope :name_include, ->(name) { where('name REGEXP ?', ".*#{name}.*") }

  after_initialize if: :new_record? do |tag|
    tag.tag_id = SecureRandom.hex
  end
end
