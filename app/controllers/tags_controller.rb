class TagsController < ApplicationController
  def index
    check_schema(index_schema, index_param)

    @search_form = TagQuery.new(index_param)
    raise BadRequest, messages: @search_form.errors.messages unless @search_form.valid?

    @tag = Tag.new
    @tags = scope_param.keys.inject(Tag.all) do |tags, key|
      value = @search_form.send(key)
      value ? tags.send(key, value) : tags
    end
    @tags = @tags.order(:name)
                 .page(@search_form.page)
                 .per(@search_form.per_page)

    render status: :ok
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

  def index_schema
    @index_schema ||= {
      type: :object,
      properties: {
        name_include: {
          type: :string,
        },
        page: {
          type: :string,
          pattern: '^[1-9][0-9]*$',
        },
        per_page: {
          type: :string,
          pattern: '^[1-9][0-9]*$',
        },
      },
    }
  end
end
