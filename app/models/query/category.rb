class Query::Category
  include ActiveModel::Model

  attribute_names = %i[name_include]
  attr_accessor(*attribute_names)

  def attributes
    self.class.attribute_names.map {|name| [name, send(name)] }.to_h
  end
end
