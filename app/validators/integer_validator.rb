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

    unless greater_than?(options[:greater_than], value)
      record.errors.add(attribute, ERROR_MESSAGE[:invalid])
      return
    end

    unless greater_than_or_equal_to?(options[:greater_than_or_equal_to], value)
      record.errors.add(attribute, ERROR_MESSAGE[:invalid])
    end
  end

  private

  def greater_than?(greater_than, value)
    return true if greater_than.nil?

    value > greater_than
  end

  def greater_than_or_equal_to?(greater_than_or_equal_to, value)
    return true if greater_than_or_equal_to.nil?

    value >= greater_than_or_equal_to
  end
end
