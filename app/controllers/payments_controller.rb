class PaymentsController < ApplicationController
  before_action :check_user, :only => [:manage]
  before_action :check_client, :except => [:manage]

  def manage
    @payment = Payment.new
    @payments = Payment.order(:date => :desc).page(params[:page])
  end

  def create
    begin
      attributes = params.require(:payments).permit(*payment_params)
      absent_keys = payment_params - attributes.symbolize_keys.keys
      raise BadRequest.new(absent_keys.map {|key| "absent_param_#{key}" }) unless absent_keys.empty?

      @payment = Payment.new(attributes)
      if @payment.save
        request.format = :js if request.xhr?
        respond_to do |format|
          format.json {render :status => :created, :template => 'payments/payment'}
          format.js {@payments = Payment.order(:date => :desc).page(params[:page])}
        end
      else
        raise BadRequest.new(@payment.errors.messages.keys.map {|key| "invalid_param_#{key}" })
      end
    rescue ActionController::ParameterMissing
      raise BadRequest.new('absent_param_payments')
    end
  end

  def show
    @payment = Payment.find_by(params.permit(:id))
    if @payment
      respond_to do |format|
        format.json {render :status => :ok, :template => 'payments/payment'}
      end
    else
      raise NotFound.new
    end
  end

  def index
    query = Query.new(params.permit(*index_params))
    if query.valid?
      @payments = index_params.inject(Payment.all) do |payments, key|
        value = query.send(key)
        value ? payments.send(key, value) : payments
      end
      respond_to do |format|
        format.json {render :status => :ok, :template => 'payments/payments'}
      end
    else
      raise BadRequest.new(query.errors.messages.keys.map {|key| "invalid_param_#{key}" })
    end
  end

  def update
    @payment = Payment.find_by(params.permit(:id))
    if @payment
      if @payment.update(params.permit(*payment_params))
        respond_to do |format|
          format.json {render :status => :ok, :template => 'payments/payment'}
        end
      else
        raise BadRequest.new(@payment.errors.messages.keys.map {|key| "invalid_param_#{key}" })
      end
    else
      raise NotFound.new
    end
  end

  def destroy
    @payment = Payment.find_by(params.permit(:id)).try(:destroy)
    if @payment
      head :no_content
    else
      raise NotFound.new
    end
  end

  def settle
    query = Settlement.new(params.permit(:interval))
    if query.valid?
      @settlement = Payment.settle(query.interval)
      respond_to do |format|
        format.json {render :status => :ok}
      end
    else
      raise BadRequest.new("#{query.errors.messages[:interval].first}_param_interval")
    end
  end

  private

  def payment_params
    %i[ payment_type date content category price ]
  end

  def index_params
    %i[ payment_type date_before date_after content_equal content_include category price_upper price_lower ]
  end
end
