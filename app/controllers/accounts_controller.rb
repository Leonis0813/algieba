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
      if params[:accounts][:from] == 'browser'
        render
      else
        render :status => :created, :json => @account
      end
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
      render :status => :ok, :json => Account.update(params.slice(*permitted_params_update))
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
    check_absent_params_for_settle

    begin
      render :status => :ok, :json => Account.settle(params[:interval])
    rescue Exception
      raise BadRequest.new(:interval, 'invalid')
    end
  end

  private

  def account_attributes
    %i[ account_type date content category price ]
  end

  def permitted_params_update
    %i[ condition with ]
  end

  def permitted_values_settle
    %i[ yearly monthly daily ]
  end

  def check_absent_params_for_create
    request_params = request.request_parameters
    raise BadRequest.new(:accounts, 'absent') unless request_params.has_key?(:accounts)
    errors = [].tap do |array|
      account_attributes.each do |param_key|
        array << param_key unless request_params[:accounts].has_key?(param_key)
      end
    end
    raise BadRequest.new(errors, 'absent') unless errors.empty?
  end

  def check_absent_params_for_update
    request_params = request.request_parameters
    raise BadRequest.new(:with, 'absent') unless request_params.has_key?(:with)
    raise BadRequest.new(:with, 'absent') if request_params[:with].empty?
  end

  def check_absent_params_for_settle
    raise BadRequest.new(:interval, 'absent') unless request.query_parameters.has_key?(:interval)
    unless request.query_parameters[:interval].match(/#{permitted_values_settle.join('|')}/)
      raise BadRequest.new(:interval, 'invalid')
    end
  end
end
