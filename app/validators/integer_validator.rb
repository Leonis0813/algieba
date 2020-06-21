class IntegerValidator < ApplicationValidator
  def validate_each(record, attribute, value)
    value = if record.respond_to?(:"#{attribute}_before_type_cast")
              record.send("#{attribute}_before_type_cast")
            else
              value
            end

    if value.nil?
      record.errors.add(attribute, ERROR_MESSAGE[:absent])
      return
    end

    unless value.is_a?(Integer)
      record.errors.add(attribute, ERROR_MESSAGE[:invalid])
      return
    end

    greater_than = options[:greater_than]
    if greater_than.present? and not value > greater_than
      record.errors.add(attribute, ERROR_MESSAGE[:invalid])
    end

    greater_than_or_equal_to = options[:greater_than_or_equal_to]
    if greater_than_or_equal_to.present? and not value >= greater_than_or_equal_to
      record.errors.add(attribute, ERROR_MESSAGE[:invalid])
    end
  end
end
