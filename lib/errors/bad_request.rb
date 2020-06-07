class BadRequest < StandardError
  attr_accessor :errors

  def initialize(messages, resource = nil)
    @errors = messages.map do |parameter, message|
      {error_code: message, parameter: parameter, resource: resource}
    end
  end
end
