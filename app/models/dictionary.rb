class Dictionary < ActiveRecord::Base
  has_many :category_dictionaries, dependent: :destroy
  has_many :categories, through: :category_dictionaries

  validates :phrase,
            presence: {message: 'invalid'}

  validates :condition,
            inclusion: {in: %w[equal include], message: 'invalid'}
end
