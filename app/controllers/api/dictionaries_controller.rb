module Api
  class DictionariesController < ApplicationController
    def create
      attributes = params.permit(:phrase, :condition, categories: [])
      absent_keys = create_params - attributes.keys.map(&:to_sym)
      error_codes = absent_keys.map {|key| "absent_param_#{key}" }
      raise BadRequest, error_codes unless absent_keys.empty?

      @dictionary = Dictionary.new(attributes.except(:categories))
      @dictionary.categories << attributes[:categories].map do |category_name|
        Category.find_or_initialize_by(name: category_name)
      end

      begin
        if @dictionary.save
          render status: :created, template: 'dictionaries/dictionary'
        else
          error_codes = @dictionary.errors.messages.keys.map do |key|
            "invalid_param_#{key}"
          end
          raise BadRequest, error_codes
        end
      rescue ActiveRecord::RecordNotUnique
        raise Duplicated, 'dictionary'
      end
    end

    def index
      query = params.permit(*index_params)
      @dictionaries = if query.empty?
                        Dictionary.all.order(:condition)
                      else
                        Dictionary.all.select do |dictionary|
                          query[:content].include?(dictionary.phrase)
                        end.sort_by(&:condition)
                      end
      render status: :ok, template: 'dictionaries/dictionaries'
    end

    private

    def create_params
      %i[phrase condition categories]
    end

    def index_params
      %i[content]
    end
  end
end
