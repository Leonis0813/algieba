class TagsController < ApplicationController
  def index
    @search_form = Query::Tag.new(index_param)

    if @search_form.valid?
      @tags = scope_param.keys.inject(Tag.all) do |tags, key|
        value = @search_form.send(key)
        value ? tags.send(key, value) : tags
      end
      @tags = @tags.order(:name).page(params[:page]).per(per_page)
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

  def per_page
    return @per_page if @per_page

    per_page = index_param[:per_page] || Kaminari.config.default_per_page
    raise BadRequest, 'invalid_param_per_page' unless per_page.to_s.match?('\A\d*\z')

    @per_page = per_page.to_i
  end
end
