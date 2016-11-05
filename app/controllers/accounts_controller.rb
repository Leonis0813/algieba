class AccountsController < ApplicationController
  before_filter :basic, :only => [:manage]

  def manage
    if login_user
      @account = Account.new
      @accounts = Account.order(:date => :desc).page(params[:page])
    else
      redirect_to login_path
    end
  end

  def create
    begin
      attributes = params.require(:accounts).permit(*account_params)
      absent_keys = account_params - attributes.symbolize_keys.keys
      raise BadRequest.new(absent_keys, 'absent') unless absent_keys.empty?

      @account = Account.new(attributes)
      if @account.save
        request.format = :js if request.xhr?
        respond_to do |format|
          format.json {render :status => :created, :template => 'accounts/account'}
          format.js {@accounts = Account.order(:date => :desc).page(params[:page])}
        end
      else
        raise BadRequest.new(@account.errors.messages.keys, 'invalid')
      end
    rescue ActionController::ParameterMissing
      raise BadRequest.new(:accounts, 'absent')
    end
  end

  def show
    @account = Account.find_by(params.permit(:id))
    if @account
      respond_to do |format|
        format.json {render :status => :ok, :template => 'accounts/account'}
      end
    else
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
      respond_to do |format|
        format.json {render :status => :ok, :template => 'accounts/accounts'}
      end
    else
      raise BadRequest.new(query.errors.messages.keys, 'invalid')
    end
  end

  def update
    @account = Account.find_by(params.permit(:id))
    if @account
      if @account.update(params.permit(*account_params))
        respond_to do |format|
          format.json {render :status => :ok, :template => 'accounts/account'}
        end
      else
        raise BadRequest.new(@account.errors.messages.keys, 'invalid')
      end
    else
      raise NotFound.new
    end
  end

  def destroy
    @account = Account.find_by(params.permit(:id)).try(:destroy)
    if @account
      head :no_content
    else
      raise NotFound.new
    end
  end

  def settle
    query = Settlement.new(params.permit(:interval))
    if query.valid?
      @settlement = Account.settle(query.interval)
      respond_to do |format|
        format.json {render :status => :ok}
      end
    else
      raise BadRequest.new(:interval, query.errors.messages[:interval].first)
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
