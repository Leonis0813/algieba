class CategoriesController < ApplicationController
  before_action :check_client

  def index
    query = params.permit(:keyword)
    @categories = query.empty? ? Category.all : Category.where(:name => query[:keyword])

    respond_to do |format|
      format.json {render :status => :ok, :template => 'categories/categories'}
    end
  end
end
