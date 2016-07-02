class AccountsController < ApplicationController
  before_filter :basic, :only => [:manage]

  def manage
    @account = Account.new
    @all_accounts = Account.all
  end

  def create
    params.permit!
    check_absent_params_for_create

    begin
      accounts = params[:accounts].slice(*account_attributes)
      accounts[:date] = 'invalid_date' unless accounts[:date] =~ /\d{4}-\d{2}-\d{2}/
      @account = Account.create!(accounts)
      if params[:accounts][:from] == 'browser'
        render
      else
        render :status => :created, :json => @account
      end
    rescue ActiveRecord::RecordInvalid => e
      raise BadRequest.new(e.record.errors.messages.keys, 'invalid')
    end
  end

  def show
    params.permit!

    begin
      render :status => :ok, :json => Account.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      raise NotFound.new
    end
  end

  def update
    params.permit!

    begin
      account = Account.find(params[:id])
      account.update!(request.request_parameters.slice(*account_attributes))
      render :status => :ok, :json => account
    rescue ActiveRecord::RecordNotFound => e
      raise NotFound.new
    rescue ActiveRecord::RecordInvalid => e
      raise BadRequest.new(e.record.errors.messages.keys, 'invalid')
    rescue ActiveRecord::RecordNotSaved => e
      raise InternalServerError.new
    end
  end

  def delete
    params.permit!

    begin
      Account.find(params[:id]).destroy!
      head :no_content
    rescue ActiveRecord::RecordNotFound => e
      raise NotFound.new
    rescue ActiveRecord::RecordNotDestroyed => e
      raise InternalServerError.new
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

  def check_absent_params_for_settle
    raise BadRequest.new(:interval, 'absent') unless request.query_parameters.has_key?(:interval)
    unless request.query_parameters[:interval].match(/#{permitted_values_settle.join('|')}/)
      raise BadRequest.new(:interval, 'invalid')
    end
  end
end
