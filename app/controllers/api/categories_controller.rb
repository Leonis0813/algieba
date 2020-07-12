module Api
  class CategoriesController < ApplicationController
    def index
      check_schema(index_schema, index_params)

      @categories = if index_params.empty?
                      Category.all
                    else
                      Category.where(name: index_params[:keyword])
                    end

      render status: :ok
    end

    private

    def index_params
      @index_params ||= request.query_parameters.slice(
        :keyword,
      )
    end

    def index_schema
      @index_schema ||= {
        type: :object,
        properties: {
          keyword: {type: :string, minLength: 1},
        },
      }
    end
  end
end
