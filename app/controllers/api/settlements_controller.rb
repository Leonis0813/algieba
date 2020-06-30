module Api
  class SettlementsController < ApplicationController
    def category
      settlement = Settlement.new(params.permit(:payment_type))
      settlement.aggregation_type = Settlement::AGGREGATION_TYPE_CATEGORY
      check_query_param(settlement, :payment_type)
      @settlements = settlement.calculate
      render status: :ok
    end

    def period
      settlement = Settlement.new(params.permit(:interval))
      settlement.aggregation_type = Settlement::AGGREGATION_TYPE_PERIOD
      check_query_param(settlement, :interval)
      @settlements = settlement.calculate
      render status: :ok
    end

    private

    def check_query_param(query, param)
      return if query.valid?

      raise BadRequest, "#{query.errors.messages[param].first}_param_#{param}"
    end
  end
end
