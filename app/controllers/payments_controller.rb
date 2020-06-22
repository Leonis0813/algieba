class PaymentsController < ApplicationController
  def index
    attribute = {per_page: Kaminari.config.default_per_page.to_s}.merge(index_param)
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
end
