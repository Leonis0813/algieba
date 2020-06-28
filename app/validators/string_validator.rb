class StringValidator < ApplicationValidator
  def validate_each(record, attribute, value)
    value = if record.respond_to?(:"#{attribute}_before_type_cast")
              record.send("#{attribute}_before_type_cast")
            else
              value
            end

    if value.blank?
      record.errors.add(attribute, ERROR_MESSAGE[:absent])
      return
    end

    unless value.is_a?(String)
      record.errors.add(attribute, ERROR_MESSAGE[:invalid])
      return
    end

    unless format?(options[:format], value)
      record.errors.add(attribute, ERROR_MESSAGE[:invalid])
    end

    unless enum?(options[:enum], value)
      record.errors.add(attribute, ERROR_MESSAGE[:invalid])
    end

    unless length?(options[:length])
      record.errors.add(attribute, ERROR_MESSAGE[:invalid])
    end
  end

  private

  def format?(format, value)
    return true if format.nil?

    value.match?(format)
  end

  def enum?(enum, value)
    return true if enum.nil?

    enum.include?(value)
  end

  def length?(length, value)
    return true if length.nil?

    if length[:maximum].present?
      value.size <= length[:maximum]
    else
      true
    end
  end
end
