class Dictionary < ApplicationRecord
  CONDITION_LIST = %w[equal include].freeze

  has_many :category_dictionaries, dependent: :destroy
  has_many :categories, through: :category_dictionaries, validate: false

  validates :dictionary_id,
            string: {format: ID_FORMAT},
            uniqueness: {message: MESSAGE_DUPLICATED}
  validates :phrase,
            string: true,
            uniqueness: {scope: 'condition', message: MESSAGE_DUPLICATED}
  validates :condition,
            string: {enum: CONDITION_LIST}
  validates :categories,
            presence: {message: ApplicationValidator::ERROR_MESSAGE[:absent]},
            associated: {message: ApplicationValidator::ERROR_MESSAGE[:invalid]},
            collection: {unique: %w[name]}

  scope :phrase_include, ->(phrase) { where('phrase REGEXP ?', ".*#{phrase}.*") }

  after_initialize if: :new_record? do |dictionary|
    dictionary.dictionary_id = SecureRandom.hex
  end
end
