module Api
  class PaymentsController < ApplicationController
    def create
      attributes = params.permit(:date, :content, :price, :payment_type, categories: [])

      absent_keys = create_params - attributes.keys.map(&:to_sym)
      error_codes = absent_keys.map {|key| "absent_param_#{key}" }
      raise BadRequest, error_codes unless absent_keys.empty?

      @payment = Payment.new(attributes.except(:categories))
      @payment.categories << attributes[:categories].map do |category_name|
        Category.find_or_initialize_by(name: category_name)
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

      attributes = params.permit(:date, :content, :price, :payment_type, categories: [])
      if attributes[:categories]
        @payment.categories = attributes[:categories].map do |category_name|
          Category.find_or_create_by(name: category_name)
        end
      end

      if @payment.update(attributes.except(:categories))
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

    private

    def create_params
      %i[payment_type date content categories price]
    end

    def index_params
      %i[
        payment_type date_before date_after content_equal content_include category
        price_upper price_lower page per_page sort order
      ]
    end
  end
end
