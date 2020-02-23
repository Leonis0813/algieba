class DictionariesController < ApplicationController
  def index
    @search_form = DictionaryQuery.new(index_param)

    if @search_form.valid?
      @dictionaries = scope_param.keys.inject(Dictionary.all) do |dictionaries, key|
        value = @search_form.send(key)
        value ? dictionaries.send(key, value) : dictionaries
      end.order(:phrase).page(@search_form.page).per(@search_form.per_page)
      @dictionary = Dictionary.new

      render status: :ok
    else
      error_codes = @search_form.errors.messages.keys.map {|key| "invalid_param_#{key}" }
      raise BadRequest, error_codes
    end
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
end
