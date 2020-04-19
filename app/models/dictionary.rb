class Dictionary < ApplicationRecord
  CONDITION_LIST = %w[equal include].freeze

  has_many :category_dictionaries, dependent: :destroy
  has_many :categories, through: :category_dictionaries

  validates :dictionary_id, :phrase, :condition,
            presence: {message: 'absent'}
  validates :dictionary_id,
            format: {with: ID_FORMAT, message: 'invalid'},
            allow_nil: true
  validates :condition,
            inclusion: {in: CONDITION_LIST, message: 'invalid'},
            allow_nil: true

  scope :phrase_include, ->(phrase) { where('phrase REGEXP ?', ".*#{phrase}.*") }

  after_initialize if: :new_record? do |dictionary|
    dictionary.dictionary_id = SecureRandom.hex
  end
end
