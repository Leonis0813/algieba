class PaymentsController < ApplicationController
  def index
    @search_form = Query.new(index_param)

    if @search_form.valid?
      @payments = index_param.keys.inject(Payment.all) do |payments, key|
        value = @search_form.send(key)
        value ? payments.send(key, value) : payments
      end
      @payment = Payment.new
      @payments = @payments.order(date: :desc).page(params[:page]).per(per_page)
      @dictionary = Dictionary.new
      render status: :ok
    else
      error_codes = @search_form.errors.messages.keys.map {|key| "invalid_param_#{key}" }
      raise BadRequest, error_codes
    end
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
    )
  end

   def per_page
     return @per_page if @per_page

     per_page = index_param[:per_page] || Kaminari.config.default_per_page
     raise BadRequest, 'invalid_param_per_page' unless per_page.to_s.match?('\A\d*\z')

     @per_page = per_page.to_i
   end
end
