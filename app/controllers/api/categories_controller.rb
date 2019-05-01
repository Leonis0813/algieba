class Api
  class CategoriesController < ApplicationController
    def index
      query = params.permit(:keyword)
      @categories = query.empty? ? Category.all : Category.where(name: query[:keyword])

      render status: :ok, template: 'categories/categories'
    end
  end
end
