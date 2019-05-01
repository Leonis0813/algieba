class Api
  class PaymentsController < ApplicationController
    def create
      begin
        attributes = params.require(:payments).permit(*payment_params)
      rescue ActionController::ParameterMissing
        raise BadRequest, 'absent_param_payments'
      end

      absent_keys = payment_params - attributes.symbolize_keys.keys
      error_codes = absent_keys.map {|key| "absent_param_#{key}" }
      raise BadRequest, error_codes unless absent_keys.empty?

      @payment = Payment.new(attributes.except(:category))
      @payment.categories << attributes[:category].split(',').map do |category_name|
        Category.find_or_create_by(name: category_name)
      end

      if @payment.save
        render status: :created, template: 'payments/payment'
      else
        error_codes = @payment.errors.messages.keys.map {|key| "invalid_param_#{key}" }
        raise BadRequest, error_codes
      end
    end

    def show
      @payment = Payment.find_by(params.permit(:id))
      raise NotFound unless @payment

      render status: :ok, template: 'payments/payment'
    end

    def index
      query = Query.new(params.permit(*index_params))
      if query.valid?
        query_params = index_params - %i[page per_page sort order]
        @payments = query_params.inject(Payment.all) do |payments, key|
          value = query.send(key)
          value ? payments.send(key, value) : payments
        end.order(query.sort => query.order).page(query.page).per(query.per_page)
        render status: :ok, template: 'payments/payments'
      else
        error_codes = query.errors.messages.keys.map {|key| "invalid_param_#{key}" }
        raise BadRequest, error_codes
      end
    end

    def update
      @payment = Payment.find_by(params.permit(:id))
      raise NotFound unless @payment

      attributes = params.permit(*payment_params)
      if attributes[:category]
        @payment.categories = attributes[:category].split(',').map do |category_name|
          Category.find_or_create_by(name: category_name)
        end
      end

      if @payment.update(attributes.except(:category))
        render status: :ok, template: 'payments/payment'
      else
        error_codes = @payment.errors.messages.keys.map {|key| "invalid_param_#{key}" }
        raise BadRequest, error_codes
      end
    end

    def destroy
      @payment = Payment.find_by(params.permit(:id)).try(:destroy)
      raise NotFound unless @payment

      head :no_content
    end

    def settle
      query = Settlement.new(params.permit(:interval))
      unless query.valid?
        raise BadRequest, "#{query.errors.messages[:interval].first}_param_interval"
      end

      @settlement = Payment.settle(query.interval)
      render status: :ok, template: 'payments/settle'
    end

    private

    def payment_params
      %i[payment_type date content category price]
    end

    def index_params
      %i[
        payment_type date_before date_after content_equal content_include category
        price_upper price_lower page per_page sort order
      ]
    end
  end
end
