class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  rescue_from BadRequest do |e|
    render status: :bad_request, json: {errors: e.errors}
  end

  rescue_from NotFound do
    head :not_found
  end

  rescue_from InternalServerError do
    head :internal_server_error
  end

  def check_schema(schema, request_parameter, resource: nil)
    errors = JSON::Validator.fully_validate(
      schema,
      request_parameter,
      errors_as_objects: true,
    )
    return if errors.empty?

    messages = errors.map do |error|
      parameter = case error[:failed_attribute]
                  when 'Required'
                    error[:message].scan(/required property of '(.*)'/).first.first
                  else
                    error[:fragment].split('/').second
                  end

      error_code = case error[:failed_attribute]
                   when 'Required'
                     ApplicationValidator::ERROR_MESSAGE[:absent]
                   when 'UniqueItems'
                     ApplicationValidator::ERROR_MESSAGE[:same_value]
                   else
                     ApplicationValidator::ERROR_MESSAGE[:invalid]
                   end

      [parameter, [error_code]]
    end.to_h

    raise BadRequest, messages: messages, resource: resource
  end
end
