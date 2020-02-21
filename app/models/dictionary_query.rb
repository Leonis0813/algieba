class DictionaryQuery < Query
  attribute_names = %i[phrase_include]
  attr_accessor(*attribute_names)

  def attributes
    super.merge(self.class.attribute_names.map {|name| [name, send(name)] }.to_h)
  end
end
