class CategoryDictionary < ApplicationRecord
  belongs_to :category
  belongs_to :dictionary

  validates :category_id,
            uniqueness: {scope: :dictionary_id, message: MESSAGE_SAME_VALUE}
end
