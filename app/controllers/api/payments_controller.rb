module Api
  class PaymentsController < ApplicationController
    before_action :check_request_payment, only: %i[show update destroy]

    def create
      @payment = Payment.new(create_params.except(:categories, :tags))
      @payment.categories = Array.wrap(create_params[:categories]).map do |name|
        Category.find_or_initialize_by(name: name)
      end
      @payment.tags = Array.wrap(create_params[:tags]).map do |name|
        Tag.find_or_initialize_by(name: name)
      end

      raise BadRequest, messages: @payment.errors.messages, resource: 'payment' unless @payment.save

      render status: :created
    end

    def show
      @payment = request_payment
      render status: :ok
    end

    def index
      query = PaymentQuery.new(index_params)
      raise BadRequest, messages: query.errors.messages unless query.valid?

      @payments = scope_params.keys.inject(Payment.all) do |payments, key|
        value = query.send(key)
        value ? payments.send(key, value) : payments
      end.order(query.sort => query.order).page(query.page).per(query.per_page)
      render status: :ok
    end

    def update
      if update_params[:categories]
        request_payment.categories = update_params[:categories].map do |category_name|
          Category.find_or_create_by(name: category_name)
        end
      end

      if update_params[:tags]
        request_payment.tags = update_params[:tags].map do |tag_name|
          Tag.find_or_create_by(name: tag_name)
        end
      end

      unless request_payment.update(update_params.except(:categories, :tags))
        raise BadRequest, messages: request_payment.errors.messages, resource: 'payment'
      end

      @payment = request_payment.reload
      render status: :ok
    end

    def destroy
      request_payment.destroy
      head :no_content
    end

    private

    def check_request_payment
      raise NotFound unless request_payment
    end

    def request_payment
      @request_payment ||= Payment.find_by(request.path_parameters.slice(:payment_id))
    end

    def create_params
      @create_params ||= request.request_parameters.slice(
        :payment_type,
        :date,
        :content,
        :categories,
        :tags,
        :price,
      )
    end

    def index_params
      @index_params ||= request.query_parameters.slice(
        :payment_type,
        :date_before,
        :date_after,
        :content_equal,
        :content_include,
        :category,
        :price_upper,
        :price_lower,
        :page,
        :per_page,
        :sort,
        :order,
      )
    end

    def update_params
      @update_params ||= request.request_parameters.slice(
        :payment_type,
        :date,
        :content,
        :categories,
        :tags,
        :price,
      )
    end

    def scope_params
      @scope_params ||= index_params.except(
        :page,
        :per_page,
        :sort,
        :order,
      )
    end
  end
end
