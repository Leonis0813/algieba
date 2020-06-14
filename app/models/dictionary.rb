class Dictionary < ApplicationRecord
  CONDITION_LIST = %w[equal include].freeze

  has_many :category_dictionaries, dependent: :destroy
  has_many :categories, through: :category_dictionaries

  validates :dictionary_id, :phrase, :condition, :categories,
            presence: {message: MESSAGE_ABSENT}
  validates :dictionary_id,
            format: {with: ID_FORMAT, message: MESSAGE_INVALID},
            uniqueness: {message: MESSAGE_DUPLICATED},
            allow_nil: true
  validates :phrase,
            uniqueness: {scope: 'condition', message: MESSAGE_DUPLICATED}
  validates :condition,
            inclusion: {in: CONDITION_LIST, message: MESSAGE_INVALID},
            allow_nil: true
  validate :array_parameters

  scope :phrase_include, ->(phrase) { where('phrase REGEXP ?', ".*#{phrase}.*") }

  after_initialize if: :new_record? do |dictionary|
    dictionary.dictionary_id = SecureRandom.hex
  end

  private

  def array_parameters
    category_names = self.categories.map(&:name)
    errors.add(:categories, MESSAGE_SAME_VALUE) if category_names.uniq.size != category_names.size
  end
end
