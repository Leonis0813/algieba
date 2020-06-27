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

    format = options[:format]
    if format.present? and not value.match?(format)
      record.errors.add(attribute, ERROR_MESSAGE[:invalid])
    end

    enum = options[:enum]
    if enum.present? and not enum.include?(value)
      record.errors.add(attribute, ERROR_MESSAGE[:invalid])
    end

    length = options[:length]
    if length.present? and not value.size <= length[:maximum]
      record.errors.add(attribute, ERROR_MESSAGE[:invalid])
    end
  end
end
