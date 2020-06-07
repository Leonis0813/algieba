class BadRequest < StandardError
  attr_accessor :errors

  def initialize(model)
    @errors = model.errors.messages.map do |parameter, message|
      {error_code: message, parameter: parameter, resource: model.class.to_s.downcase}
    end
  end
end
