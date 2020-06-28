class DateValidator < ApplicationValidator
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

    if [String, Date].none? {|klass| value.is_a?(klass) }
      record.errors.add(attribute, ERROR_MESSAGE[:invalid])
      return
    end

    return unless value.is_a?(String)

    Date.parse(value) rescue record.errors.add(attribute, ERROR_MESSAGE[:invalid])
  end
end
