class PaymentsController < ApplicationController
  def index
    @search_form = Query.new(params.permit(*index_params))
    per_page = request.query_parameters[:per_page]
    raise BadRequest.new('invalid_param_per_page') if per_page and not per_page =~ /\A\d*\z/
    @per_page = per_page ? per_page.to_i : Kaminari.config.default_per_page
    if @search_form.valid?
      @payments = index_params.inject(Payment.all) do |payments, key|
        value = @search_form.send(key)
        value ? payments.send(key, value) : payments
      end
      @payment = Payment.new
      @payments = @payments.order(:date => :desc).page(params[:page]).per(@per_page)
      render :status => :ok
    else
      raise BadRequest.new(@search_form.errors.messages.keys.map {|key| "invalid_param_#{key}" })
    end
  end

  private

  def index_params
    %i[ payment_type date_before date_after content_equal content_include category price_upper price_lower ]
  end
end
