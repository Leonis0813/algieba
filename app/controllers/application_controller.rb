class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  rescue_from Duplicated do |e|
    render status: :bad_request, json: {errors: e.errors}
  end

  rescue_from BadRequest do |e|
    render status: :bad_request, json: {errors: e.errors}
  end

  rescue_from NotFound do
    head :not_found
  end

  rescue_from InternalServerError do
    head :internal_server_error
  end

  def check_absent_param(request_param, required_param_keys)
    absent_keys = required_param_keys - request_param.keys.map(&:to_sym)
    return if absent_keys.empty?

    error_codes = absent_keys.map {|key| "absent_param_#{key}" }
    raise BadRequest, error_codes
  end
end
