class CategoriesController < ApplicationController
  def index
    query = params.permit(:keyword)
    categories = Category.where(:name => query[:keyword])

    respond_to do |format|
      format.json {render :status => :ok, :template => 'categories/categories'}
    end
  end
end
