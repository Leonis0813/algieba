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

  def index
    params.permit!

    begin
      render :status => :ok, :json => Account.index(request.request_parameters)
    rescue ActiveRecord::RecordInvalid => e
      raise BadRequest.new(e.record.errors.messages.keys, 'invalid')
    end
  end

  def update
    params.permit!

    begin
      account = Account.find(params[:id])
      request_params = request.request_parameters
      request_params[:date] = 'invalid_date' if request_params[:date] and not request_params[:date] =~ /\A\d{4}-\d{2}-\d{2}\z/
      account.update!(request_params.slice(*account_attributes))
      render :status => :ok, :json => account
    rescue ActiveRecord::RecordNotFound => e
      raise NotFound.new
    rescue ActiveRecord::RecordInvalid => e
      raise BadRequest.new(e.record.errors.messages.keys, 'invalid')
    rescue ActiveRecord::RecordNotSaved => e
      raise InternalServerError.new
    end
  end

  def destroy
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

    begin
      render :status => :ok, :json => Account.settle(params[:interval])
    rescue ArgumentError => e
      raise BadRequest.new(:interval, e.message)
    end
  end

  private

  def account_attributes
    %i[ account_type date content category price ]
  end

  def check_absent_params_for_create
    request_params = request.request_parameters
    raise BadRequest.new(:accounts, 'absent') unless request_params[:accounts]
    request_keys = request_params[:accounts].slice(*account_attributes).keys.map(&:to_sym)
    absent_keys = account_attributes - request_keys
    raise BadRequest.new(absent_keys, 'absent') unless absent_keys.empty?
  end
end
