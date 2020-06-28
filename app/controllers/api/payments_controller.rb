module Api
  class PaymentsController < ApplicationController
    before_action :check_request_payment, only: %i[show update destroy]

    def create
      # remove after removing capybara
      price = if create_params[:price]
                create_params[:price].to_i rescue create_params[:price]
              end
      attribute = create_params.except(:categories, :tags).merge(price: price)
      @payment = Payment.new(attribute)
      @payment.categories = Array.wrap(create_params[:categories]).map do |name|
        category = Category.find_by(name: name.to_s) || Category.new(name: name)
        if category.invalid?
          messages = {categories: [ApplicationValidator::ERROR_MESSAGE[:invalid]]}
          raise BadRequest, messages: messages, resource: 'payment'
        end
        category
      end

      @payment.tags = Array.wrap(create_params[:tags]).map do |name|
        tag = Tag.find_by(name: name.to_s) || Tag.new(name: name)
        if tag.invalid?
          messages = {tags: [ApplicationValidator::ERROR_MESSAGE[:invalid]]}
          raise BadRequest, messages: messages, resource: 'payment'
        end
        tag
      end

      unless @payment.save
        raise BadRequest, messages: @payment.errors.messages, resource: 'payment'
      end

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
        begin
          request_payment.categories = update_params[:categories].map do |category_name|
            Category.find_by(name: category_name.to_s) ||
              Category.create!(name: category_name)
          end
        rescue ActiveRecord::RecordInvalid
          messages = {categories: [ApplicationValidator::ERROR_MESSAGE[:invalid]]}
          raise BadRequest, messages: messages, resource: 'payment'
        rescue ActiveRecord::RecordNotUnique
          messages = {name: [ApplicationValidator::ERROR_MESSAGE[:duplicated]]}
          raise BadRequest, messages: messages, resource: 'category'
        end
      end

      if update_params[:tags]
        begin
          request_payment.tags = update_params[:tags].map do |tag_name|
            Tag.find_by(name: tag_name.to_s) || Tag.create!(name: tag_name)
          end
        rescue ActiveRecord::RecordInvalid
          messages = {tags: [ApplicationValidator::ERROR_MESSAGE[:invalid]]}
          raise BadRequest, messages: messages, resource: 'payment'
        rescue ActiveRecord::RecordNotUnique
          messages = {name: [ApplicationValidator::ERROR_MESSAGE[:duplicated]]}
          raise BadRequest, messages: messages, resource: 'tag'
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
