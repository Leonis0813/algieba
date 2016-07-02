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
      accounts[:date] = 'invalid_date' unless accounts[:date] =~ /\A\d{4}-\d{2}-\d{2}\z/
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
    raise BadRequest.new(:interval, 'absent') unless request.query_parameters[:interval]

    begin
      render :status => :ok, :json => Account.settle(params[:interval])
    rescue ArgumentError
      raise BadRequest.new(:interval, 'invalid')
    end
  end

  private

  def account_attributes
    %i[ account_type date content category price ]
  end

  def check_absent_params_for_create
    request_params = request.request_parameters
    raise BadRequest.new(:accounts, 'absent') unless request_params[:accounts]
    absent_keys = account_attributes - request_params[:accounts].slice(*account_attributes).keys
    raise BadRequest.new(absent_keys, 'absent') unless absent_keys.empty?
  end
end
