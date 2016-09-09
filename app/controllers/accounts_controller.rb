class AccountsController < ApplicationController
  before_filter :basic, :only => [:manage]

  def manage
    @account = Account.new
    @accounts = Account.order(:date => :desc).page(params[:page])
  end

  def create
    begin
      attributes = params.require(:accounts).permit(*account_params)
      absent_keys = account_params - attributes.keys
      raise BadRequest.new(absent_keys, 'absent') unless absent_keys.empty?

      @account = Account.new(attributes)
      if @account.save
        respond_to do |format|
          format.json { render :status => :created }
          format.js { @accounts = Account.order(:date => :desc).page(params[:page]) }
        end
      else
        raise BadRequest.new(@account.errors.messages.keys, 'invalid')
      end
    rescue ActionController::ParameterMissing
      raise BadRequest.new(:accounts, 'absent')
    end
  end

  def show
    begin
      @account = Account.find(params.permit(:id))
      render :status => :ok
    rescue ActiveRecord::RecordNotFound => e
      raise NotFound.new
    end
  end

  def index
    query = Query.new(params.permit(*index_params))
    if query.valid?
      @accounts = index_params.inject(Account.all) do |accounts, key|
        value = query.send(key)
        value ? accounts.send(key, value) : accounts
      end
      render :status => :ok
    else
      raise BadRequest.new(query.errors.messages.keys, 'invalid')
    end
  end

  def update
    begin
      @account = Account.find(params[:id])
      if @account.update(params.permit(*account_params))
        render :status => :ok
      else
        raise BadRequest.new(@account.errors.messages.keys, 'invalid')
      end
    rescue ActiveRecord::RecordNotFound => e
      raise NotFound.new
    end
  end

  def destroy
    begin
      Account.find(params.permit(:id)).destroy!
      head :no_content
    rescue ActiveRecord::RecordNotFound => e
      raise NotFound.new
    rescue ActiveRecord::RecordNotDestroyed => e
      raise InternalServerError.new
    end
  end

  def settle
    query = Settlement.new(params.permit(:interval))
    if query.valid?
      @settlement = Account.settle(query.interval)
      render :status => :ok
    else
      raise BadRequest.new(query.errors.messages.keys, 'invalid')
    end
  end

  private

  def account_params
    %i[ account_type date content category price ]
  end

  def index_params
    %i[ account_type date_before date_after content_equal content_include category price_upper price_lower ]
  end
end
