class DictionariesController < ApplicationController
  def index
    check_schema(index_schema, index_param)

    @search_form = DictionaryQuery.new(index_param)
    raise BadRequest, messages: @search_form.errors.messages unless @search_form.valid?

    @dictionary = Dictionary.new
    @dictionaries = scope_param.keys.inject(Dictionary.all) do |dictionaries, key|
      value = @search_form.send(key)
      value ? dictionaries.send(key, value) : dictionaries
    end.order(:phrase).page(@search_form.page).per(@search_form.per_page)
  end

  private

  def index_param
    @index_param ||= request.query_parameters.slice(
      :phrase_include,
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
        phrase_include: {type: :string, minLength: 1},
        page: {type: :string, pattern: '^[1-9][0-9]*$'},
        per_page: {type: :string, pattern: '^[1-9][0-9]*$'},
      },
    }
  end
end
