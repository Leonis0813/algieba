class Dictionary < ApplicationRecord
  has_many :category_dictionaries, dependent: :destroy
  has_many :categories, through: :category_dictionaries

  validates :dictionary_id, :phrase, :condition,
            presence: {message: 'absent'}
  validates :dictionary_id,
            format: {with: /\A[0-9a-f]{32}\z/, message: 'invalid'},
            allow_nil: true
  validates :condition,
            inclusion: {in: %w[equal include], message: 'invalid'},
            allow_nil: true
end
