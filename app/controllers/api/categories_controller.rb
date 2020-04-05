module Api
  class CategoriesController < ApplicationController
    def index
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
  end
end
