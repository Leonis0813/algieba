class PaymentsController < ApplicationController
  before_action :check_user, :only => [:manage]
  before_action :check_client, :except => [:manage]

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
        respond_to do |format|
          format.json {render :status => :created, :template => 'payments/payment'}
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
    @search_form = SearchForm.new(params.permit(*index_params))
    if @search_form.valid?
      @payments = index_params.inject(Payment.all) do |payments, key|
        value = @search_form.send(key)
        value ? payments.send(key, value) : payments
      end
      respond_to do |format|
        if cookies[:algieba]
          request.format = :html
          format.html do
            @payment = Payment.new
            @payments = @payments.order(:date => :desc).page(params[:page])
            render :status => :ok, :template => 'payments/manage'
          end
        elsif check_client
          format.json {render :status => :ok, :template => 'payments/payments'}
        end
      end
    else
      raise BadRequest.new(@search_form.errors.messages.keys.map {|key| "invalid_param_#{key}" })
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
      respond_to do |format|
        format.json {head :no_content}
      end
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
