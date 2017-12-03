class PaymentsController < ApplicationController
  before_action :check_user

  def index
    @search_form = Query.new(params.permit(*index_params))
    @per_page = request.query_parameters[:per_page] || 50
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
