class AccountsController < ApplicationController
  before_filter :basic, :only => [:register]

  def register
    @account = Account.new
    @all_accounts = Account.all
  end

  def create
    params.permit!
    check_absent_params_for_create

    begin
      @account = Account.create!(params[:accounts].slice(*required_params_create))
      render if params[:accounts][:from] == 'browser'
      render :status => :created, :json => @account
    rescue ActiveRecord::RecordInvalid => e
      raise BadRequest.new(e.record.errors.messages.keys, 'invalid')
    end
  end

  def read
    params.permit!

    result, obj = Account.show params
    if result
      render :status => :ok, :json => obj
    else
      errors = obj.map{|param| {:error_code => "invalid_param_#{param}"} }
      render :status => :bad_request, :json => errors
    end
  end

  def update
    params.permit!

    if params[:with]
      result, obj = Account.update params
      if result
        render :status => :ok, :json => obj
      else
        errors = obj.map{|param| {:error_code => "invalid_param_#{param}"} }
        render :status => :bad_request, :json => errors        
      end
    else
      render :status => :bad_request, :json => [{:error_code => 'absent_param_with'}]
    end
  end

  def delete
    params.permit!

    result, obj = Account.destroy params
    if result
      render :status => :no_content, :nothing => true
    else
      errors = obj.map{|param| {:error_code => "invalid_param_#{param}"} }
      render :status => :bad_request, :json => errors        
    end
  end

  def settle
    params.permit!

    if params[:interval]
      result, obj = Account.settle params[:interval]
      if result
        render :status => :ok, :json => obj
      else
        render :status => :bad_request, :json => [{:error_code => 'invalid_param_interval'}]
      end
    else
      render :status => :bad_request, :json => [{:error_code => 'absent_param_interval'}]
    end
  end

  private

  def required_params_create
    %i[ account_type date content category price ]
  end

  def check_absent_params_for_create
    prefix = 'absent'
    raise BadRequest.new('accounts', prefix) unless request.request_parameters.has_key?('accounts')
    errors = [].tap do |array|
      required_params_create.each do |param_key|
        array << param_key unless request.request_parameters[:accounts].has_key?(param_key)
      end
    end
    raise BadRequest.new(errors, prefix) unless errors.empty?
  end
end
