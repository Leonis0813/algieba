module Api
  class PaymentsController < ApplicationController
    before_action :check_request_payment, only: %i[show update destroy]

    def create
      check_schema(create_schema, create_params, resource: 'payment')

      attribute = create_params.except(:categories, :tags)
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
      check_schema(index_schema, index_params)

      query = PaymentQuery.new(index_params)
      raise BadRequest, messages: query.errors.messages unless query.valid?

      @payments = scope_params.keys.inject(Payment.all) do |payments, key|
        value = query.send(key)
        value ? payments.send(key, value) : payments
      end.order(query.sort => query.order).page(query.page).per(query.per_page)
      render status: :ok
    end

    def update
      check_schema(update_schema, update_params, resource: 'payment')

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

    def create_schema
      @create_schema ||= {
        type: :object,
        required: %i[payment_type date content price categories],
        properties: {
          payment_type: {
            type: :string,
            enum: Payment::PAYMENT_TYPE_LIST,
          },
          date: {
            type: :string,
            format: :date,
          },
          content: {
            type: :string,
            minLength: 1,
          },
          price: {
            type: :integer,
            minimum: 1,
          },
          categories: {
            type: :array,
            items: {
              type: :string,
              minLength: 1,
            },
            minItems: 1,
            uniqueItems: true,
          },
          tags: {
            type: :array,
            items: {
              type: :string,
              minLength: 1,
              maxLength: 10,
            },
            uniqueItems: true,
          },
        },
      }
    end

    def index_schema
      @index_schema ||= {
        type: :object,
        properties: {
          payment_type: {
            type: :string,
            enum: Payment::PAYMENT_TYPE_LIST,
          },
          date_before: {
            type: :string,
            format: :date,
          },
          date_after: {
            type: :string,
            format: :date,
          },
          content_equal: {
            type: :string,
            minLength: 1,
          },
          content_include: {
            type: :string,
            minLength: 1,
          },
          category: {
            type: :string,
            minLength: 1,
          },
          price_upper: {
            type: :string,
            pattern: '^([1-9][0-9]*|0)$',
          },
          price_lower: {
            type: :string,
            pattern: '^([1-9][0-9]*|0)$',
          },
          page: {
            type: :string,
            pattern: '^[1-9][0-9]*$',
          },
          per_page: {
            type: :string,
            pattern: '^[1-9][0-9]*$',
          },
          sort: {
            type: :string,
            enum: PaymentQuery::SORT_LIST,
          },
          order: {
            type: :string,
            enum: Query::ORDER_LIST,
          },
        },
      }
    end

    def update_schema
      @update_schema ||= {
        type: :object,
        properties: {
          payment_type: {
            type: :string,
            enum: Payment::PAYMENT_TYPE_LIST,
          },
          date: {
            type: :string,
            format: :date,
          },
          content: {
            type: :string,
            minLength: 1,
          },
          price: {
            type: :integer,
            minimum: 1,
          },
          categories: {
            type: :array,
            items: {
              type: :string,
              minLength: 1,
            },
            minItems: 1,
            uniqueItems: true,
          },
          tags: {
            type: :array,
            items: {
              type: :string,
              minLength: 1,
              maxLength: 10,
            },
            uniqueItems: true,
          },
        },
      }
    end
  end
end
