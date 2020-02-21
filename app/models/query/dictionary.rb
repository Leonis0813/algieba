class Query::Dictionary
  include ActiveModel::Model

  attribute_names = %i[phrase_include]
  attr_accessor(*attribute_names)
end
