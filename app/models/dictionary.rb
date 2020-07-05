class Dictionary < ApplicationRecord
  CONDITION_LIST = %w[equal include].freeze

  has_many :category_dictionaries, dependent: :destroy
  has_many :categories, through: :category_dictionaries, validate: false

  validates :dictionary_id,
            string: {format: ID_FORMAT},
            uniqueness: {message: MESSAGE_DUPLICATED}
  validates :phrase,
            uniqueness: {scope: 'condition', message: MESSAGE_DUPLICATED}
  validates :categories,
            associated: {message: ApplicationValidator::ERROR_MESSAGE[:invalid]},

  scope :phrase_include, ->(phrase) { where('phrase REGEXP ?', ".*#{phrase}.*") }

  after_initialize if: :new_record? do |dictionary|
    dictionary.dictionary_id = SecureRandom.hex
  end
end
