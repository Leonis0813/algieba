date = lambda {|value|
  begin
    Date.parse(value)
  rescue ArgumentError
    raise JSON::Schema::CustomFormatError, 'must be in format: YYYY-MM-DD'
  end
}
JSON::Validator.register_format_validator(:date, date)
