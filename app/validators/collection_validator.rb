class CollectionValidator < ApplicationValidator
  def validate_each(record, attribute, value)
    options[:unique].each do |attribute_name|
      values = value.map {|object| object.send(attribute_name) }
      if values.uniq.size != values.size
        record.errors.add(attribute, ERROR_MESSAGE[:same_value])
        return
      end
    end
  end
end
