class Dictionary < ActiveRecord::Base
  has_many :category_dictionaries, dependent: :destroy
  has_many :categories, through: :category_dictionaries

  validates :phrase, :condition,
            presence: {message: 'absent'}
  validates :condition,
            inclusion: {in: %w[equal include], message: 'invalid'},
            allow_nil: true
end
