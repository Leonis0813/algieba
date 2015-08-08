class AccountsController < ApplicationController
  def create
    result = check_request_body params
    if result.empty?
      account = Account.new
      result, obj = account.create
      if result
        render :status => :created, :json => obj
      else
        errors = obj.map{|param| :error_code => "invalid_value_#{param.to_s}" }
        render :status => :bad_request, :json => errors
      end
    else
      errors = result.map{|param| :error_code => "absent_param_#{param.to_s}" }
      render :status => :bad_request, :json => errors
    end
  end

  def read
    if check_request_body params

    else

    end
  end

  def update
    if check_request_body params

    else

    end
  end

  def delete
    if check_request_body params

    else

    end
  end

  def settle
    if check_request_body params

    else

    end
  end

  private

  def check_request_body(request_params)
    absent_params = []
    case request_params[:action]
    when :create
      absent_params << :date unless request_params[:date]
      absent_params << :content unless request_params[:content]
      absent_params << :category unless request_params[:category]
      absent_params << :price unless request_params[:price]
    when :read
      return true
    when :update
      return true
    when :delete
      return true
    when :settle
      return true
    else
      return false
    end
    absent_params
  end
end
