class Api::PaymentsController < ApplicationController
  def create
    begin
      attributes = params.require(:payments).permit(*payment_params)
      absent_keys = payment_params - attributes.symbolize_keys.keys
      raise BadRequest.new(absent_keys.map {|key| "absent_param_#{key}" }) unless absent_keys.empty?

      @payment = Payment.new(attributes.except(:category))
      @payment.categories << attributes[:category].split(',').map do |category_name|
        Category.find_or_create_by(:name => category_name)
      end

      if @payment.save
        render :status => :created, :template => 'payments/payment'
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
      render :status => :ok, :template => 'payments/payment'
    else
      raise NotFound.new
    end
  end

  def index
    query = Query.new(params.permit(*index_params))
    if query.valid?
      @payments = (index_params - %i[ page per_page ]).inject(Payment.all) do |payments, key|
        value = query.send(key)
        value ? payments.send(key, value) : payments
      end.page(query.page).per(query.per_page)
      render :status => :ok, :template => 'payments/payments'
    else
      raise BadRequest.new(query.errors.messages.keys.map {|key| "invalid_param_#{key}" })
    end
  end

  def update
    @payment = Payment.find_by(params.permit(:id))
    if @payment
      attributes = params.permit(*payment_params)
      if attributes[:category]
        @payment.categories = attributes[:category].split(',').map do |category_name|
          Category.find_or_create_by(:name => category_name)
        end
      end

      if @payment.update(attributes.except(:category))
        render :status => :ok, :template => 'payments/payment'
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
      render :status => :ok, :template => 'payments/settle'
    else
      raise BadRequest.new("#{query.errors.messages[:interval].first}_param_interval")
    end
  end

  private

  def payment_params
    %i[ payment_type date content category price ]
  end

  def index_params
    %i[ payment_type date_before date_after content_equal content_include category
        price_upper price_lower page per_page sort order ]
  end
end
