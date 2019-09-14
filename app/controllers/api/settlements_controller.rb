module Api
  class SettlementsController < ApplicationController
    def category
      query = Settlement.new(params.permit(:payment_type))
      query.aggregation_type = Settlement::AGGREGATION_TYPE_CATEGORY
      check_query_param(query, :payment_type)
      @settlements = Settlement.calculate
      render status: :ok, template: 'settlements/category'
    end

    def period
      query = Settlement.new(params.permit(:interval))
      query.aggregation_type = Settlement::AGGREGATION_TYPE_PERIOD
      check_query_param(query, :interval)
      @settlements = Settlement.calculate
      render status: :ok, template: 'settlements/period'
    end

    private

    def check_query_param(query, param)
      unless query.valid?
        raise BadRequest, "#{query.errors.messages[param].first}_param_#{param}"
      end
    end
  end
end
