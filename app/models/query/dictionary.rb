class Query::Dictionary
  include ActiveModel::Model

  attribute_names = %i[phrase_include]
  attr_accessor(*attribute_names)

  def attributes
    self.class.attribute_names.map {|name| [name, send(name)] }.to_h
  end
end
