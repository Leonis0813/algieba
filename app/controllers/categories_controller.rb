class CategoriesController < ApplicationController
  def index
    @search_form = CategoryQuery.new(index_param)

    if @search_form.valid?
      @categories = scope_param.keys.inject(Category.all) do |categories, key|
        value = @search_form.send(key)
        value ? categories.send(key, value) : categories
      end.order(:name).page(@search_form.page).per(@search_form.per_page)

      render status: :ok
    else
      error_codes = @search_form.errors.messages.keys.map {|key| "invalid_param_#{key}" }
      raise BadRequest, error_codes
    end
  end

  private

  def index_param
    @index_param ||= request.query_parameters.slice(
      :name_include,
      :page,
      :per_page,
    )
  end

  def scope_param
    @scope_param ||= index_param.except(
      :page,
      :per_page,
    )
  end
end
