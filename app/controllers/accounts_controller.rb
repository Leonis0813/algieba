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
      @account = Account.create!(params[:accounts].slice(*account_attributes))
      render if params[:accounts][:from] == 'browser'
      render :status => :created, :json => @account
    rescue ActiveRecord::RecordInvalid => e
      raise BadRequest.new(e.record.errors.messages.keys, 'invalid')
    end
  end

  def read
    params.permit!

    begin
      render :status => :ok, :json => Account.show(params.slice(*account_attributes))
    rescue ActiveRecord::RecordInvalid => e
      raise BadRequest.new(e.record.errors.messages.keys, 'invalid')
    end
  end

  def update
    params.permit!
    check_absent_params_for_update

    begin
      render :status => :ok, :json => Account.update(params.slice(*required_params_update))
    rescue ActiveRecord::RecordInvalid => e
      raise BadRequest.new(e.record.errors.messages.keys, 'invalid')
    end
  end

  def delete
    params.permit!

    begin
      Account.destroy params.slice(*account_attributes)
      render :status => :no_content, :nothing => true
    rescue ActiveRecord::RecordInvalid => e
      raise BadRequest.new(e.record.errors.messages.keys, 'invalid')
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

  def account_attributes
    %i[ account_type date content category price ]
  end

  def permitted_params_update
    %i[ condition with ]
  end

  def check_absent_params_for_create
    prefix = 'absent'
    raise BadRequest.new(:accounts, prefix) unless request.request_parameters.has_key?(:accounts)
    errors = [].tap do |array|
      required_params_create.each do |param_key|
        array << param_key unless request.request_parameters[:accounts].has_key?(param_key)
      end
    end
    raise BadRequest.new(errors, prefix) unless errors.empty?
  end

  def check_absent_params_for_update
    prefix = 'absent'
    raise BadRequest.new(:with, prefix) unless request.request_parameters.has_key?(:with)
    raise BadRequest.new(:with, prefix) unless request.request_parameters[:with].empty?
  end
end
