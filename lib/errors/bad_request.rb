class BadRequest < StandardError
  attr_accessor :errors

  def initialize(messages: {}, resource: nil)
    @errors = messages.map do |parameter, error_codes|
      error_codes.map do |error_code|
        {error_code: error_code, parameter: parameter, resource: resource}
      end
    end.flatten
  end
end
