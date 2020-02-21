class Query::Category
  include ActiveModel::Model

  attribute_names = %i[name_include]
  attr_accessor(*attribute_names)
end
