class CategoryDictionary < ActiveRecord::Base
  belongs_to :category
  belongs_to :dictionary
end
