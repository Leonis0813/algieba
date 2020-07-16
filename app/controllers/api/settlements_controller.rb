module Api
  class SettlementsController < ApplicationController
    def category
      check_schema(category_schema, category_param)
      settlement = Settlement.new(category_param)
      settlement.aggregation_type = Settlement::AGGREGATION_TYPE_CATEGORY
      check_query_param(settlement, :payment_type)
      @settlements = settlement.calculate
      render status: :ok
    end

    def period
      check_schema(period_schema, period_param)
      settlement = Settlement.new(period_param)
      settlement.aggregation_type = Settlement::AGGREGATION_TYPE_PERIOD
      check_query_param(settlement, :interval)
      @settlements = settlement.calculate
      render status: :ok
    end

    private

    def check_query_param(query, param)
      return if query.valid?

      raise BadRequest, messages: query.errors.messages
    end

    def category_param
      @category_param ||= request.query_parameters.slice(
        :payment_type,
      )
    end

    def period_param
      @period_param ||= request.query_parameters.slice(
        :interval,
      )
    end

    def category_schema
      @category_schema ||= {
        type: :object,
        required: %i[payment_type],
        properties: {
          payment_type: {type: :string, enum: Payment::PAYMENT_TYPE_LIST},
        },
      }
    end

    def period_schema
      @period_schema ||= {
        type: :object,
        required: %i[interval],
        properties: {
          interval: {type: :string, enum: Settlement::INTERVALS},
        },
      }
    end
  end
end
