class Tag < ApplicationRecord
  has_many :payment_tags, dependent: :destroy
  has_many :payments, through: :payment_tags

  validates :tag_id,
            string: {format: ID_FORMAT},
            uniqueness: {message: MESSAGE_DUPLICATED}
  validates :name,
            string: {length: {maximum: 10}},
            uniqueness: {message: MESSAGE_DUPLICATED}

  scope :name_include, ->(name) { where('name REGEXP ?', ".*#{name}.*") }

  after_initialize if: :new_record? do |tag|
    tag.tag_id = SecureRandom.hex
  end
end
