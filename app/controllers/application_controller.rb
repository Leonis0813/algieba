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

  rescue_from BadRequest do |e|
    render :status => :bad_request, :json => e.errors
  end

  private

  def basic
    authenticate_or_request_with_http_basic do |user, pass|
      user == 'dev' && pass == '.dev'
    end
  end
end
