class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  class BadRequest < Exception
    attr_accessor :errors

    def initialize(errors, prefix)
      @errors = Array.wrap(errors).map do |error|
        {:error_code => "#{prefix}_param_#{error}"}
      end
    end
  end

  class NotFound < Exception ; end
  class InternalServerError < Exception ; end

  rescue_from BadRequest do |e|
    render :status => :bad_request, :json => e.errors
  end

  rescue_from NotFound do |e|
    head :not_found
  end

  rescue_from InternalServerError do |e|
    head :internal_server_error
  end

  private

  def basic
    authenticate_or_request_with_http_basic do |user, pass|
      user == 'dev' && pass == '.dev'
    end
  end
end
