class AccountsController < ApplicationController
  def create
    params.permit!
    result = check_request_body params
    if result.empty?
      account = Account.new
      result, obj = account.create params
      if result
        render :status => :created, :json => obj
      else
        errors = obj.map{|param| {:error_code => "invalid_value_#{param}"} }
        render :status => :bad_request, :json => errors
      end
    else
      errors = result.map{|param| {:error_code => "absent_param_#{param}"} }
      render :status => :bad_request, :json => errors
    end
  end

  def read
    params.permit!
    result = check_request_body params
    if result.empty?
      result, obj = Account.show params
      if result
        render :status => :ok, :json => obj
      else
        errors = obj.map{|param| {:error_code => "invalid_value_#{param}"} }
        render :status => :bad_request, :json => errors
      end
    else
      errors = result.map{|param| {:error_code => "absent_param_#{param}"} }
      render :status => :bad_request, :json => errors
    end
  end

  def update
    params.permit!
    result = check_request_body params
    if result.empty?
      result, obj = Account.new.update params
      if result
        render :status => :ok, :json => obj
      else
        errors = obj.map{|param| {:error_code => "invalid_value_#{param}"} }
        render :status => :bad_request, :json => errors        
      end
    else
      errors = result.map{|param| {:error_code => "absent_param_#{param}"} }
      render :status => :bad_request, :json => errors
    end
  end

  def delete
    params.permit!
    result = check_request_body params
    if result.empty?
      result, obj = Account.new.destroy params
      if result
        render :status => :no_content, :nothing => true
      else
        errors = obj.map{|param| {:error_code => "invalid_value_#{param}"} }
        render :status => :bad_request, :json => errors        
      end
    else
      errors = result.map{|param| {:error_code => "absent_param_#{param}"} }
      render :status => :bad_request, :json => errors
    end
  end

  def settle
    params.permit!
    result = check_request_body params
    if result.empty?
      result, obj = Account.new.settle params[:period]
      if result
        render :status => :ok, :json => obj
      else
        errors = obj.map{|param| {:error_code => "invalid_value_#{param}"} }
        render :status => :bad_request, :json => errors        
      end
    else
      errors = result.map{|param| {:error_code => "absent_param_#{param}"} }
      render :status => :bad_request, :json => errors
    end
  end

  private

  def check_request_body(request_params)
    absent_params = []
    case request_params[:action]
    when 'create'
      account = params[:accounts]
      absent_params << :account_type unless account[:account_type]
      absent_params << :date unless account[:date]
      absent_params << :content unless account[:content]
      absent_params << :category unless account[:category]
      absent_params << :price unless account[:price]
    when 'read'
    when 'update'
      absent_params << :with if not request_params[:with] or request_params[:with].empty?
    when 'delete'
    when 'settle'
      absent_params << :period unless request_params[:period]
    else
      return false
    end
    absent_params
  end
end
