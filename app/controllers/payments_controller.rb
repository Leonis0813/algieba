class PaymentsController < ApplicationController
  def index
    attribute = {'per_page' => Kaminari.config.default_per_page.to_s}.merge(index_param)
    check_schema(index_schema, attribute)

    @search_form = PaymentQuery.new(attribute)
    raise BadRequest, messages: @search_form.errors.messages unless @search_form.valid?

    @payment = Payment.new
    @payments = scope_param.keys.inject(Payment.all) do |payments, key|
      value = @search_form.send(key)
      value ? payments.send(key, value) : payments
    end
    @payments = @payments.order(date: :desc)
                         .page(@search_form.page)
                         .per(@search_form.per_page)

    render status: :ok
  end

  private

  def index_param
    @index_param ||= request.query_parameters.slice(
      :payment_type,
      :date_before,
      :date_after,
      :content_equal,
      :content_include,
      :category,
      :tag,
      :price_upper,
      :price_lower,
      :page,
      :per_page,
      :sort,
      :order,
    )
  end

  def scope_param
    @scope_param ||= index_param.except(
      :page,
      :per_page,
      :sort,
      :order,
    )
  end

  def index_schema
    @index_schema ||= {
      type: :object,
      properties: {
        payment_type: {type: :string, enum: Payment::PAYMENT_TYPE_LIST},
        date_before: {type: :string, format: :date},
        date_after: {type: :string, format: :date},
        content_equal: {type: :string, minLength: 1},
        content_include: {type: :string, minLength: 1},
        category: {type: :string, minLength: 1},
        tag: {type: :string, minLength: 1},
        price_upper: {type: :string, pattern: '^([1-9][0-9]*|0)$'},
        price_lower: {type: :string, pattern: '^([1-9][0-9]*|0)$'},
        page: {type: :string, pattern: '^[1-9][0-9]*$'},
        per_page: {type: :string, pattern: '^[1-9][0-9]*$'},
        sort: {type: :string, enum: PaymentQuery::SORT_LIST},
        order: {type: :string, enum: Query::ORDER_LIST},
      },
    }
  end
end
