module Api
  class DictionariesController < ApplicationController
    def create
      check_schema(create_schema, create_params, resource: 'dictionary')

      @dictionary = Dictionary.new(create_params.except(:categories))
      @dictionary.categories << Array.wrap(create_params[:categories]).map do |name|
        Category.find_or_initialize_by(name: name)
      end

      unless @dictionary.save
        raise BadRequest, messages: @dictionary.errors.messages, resource: 'dictionary'
      end

      render status: :created
    end

    def index
      check_schema(index_schema, index_params)

      @dictionaries = if index_params.empty?
                        Dictionary.all.order(:condition)
                      else
                        dictionaries = Dictionary.where(index_params.except(:content))
                        if index_params.key?(:content)
                          dictionaries = dictionaries.select do |dictionary|
                            index_params[:content].include?(dictionary.phrase)
                          end
                        end
                        dictionaries.sort_by(&:condition)
                      end
      render status: :ok
    end

    private

    def create_params
      @create_params ||= request.request_parameters.slice(
        :phrase,
        :condition,
        :categories,
      )
    end

    def index_params
      @index_params ||= request.query_parameters.slice(
        :phrase,
        :condition,
        :content,
      )
    end

    def create_schema
      @create_schema ||= {
        type: :object,
        required: %i[phrase condition categories],
        properties: {
          phrase: {
            type: :string,
          },
          condition: {
            type: :string,
            enum: Dictionary::CONDITION_LIST,
          },
          categories: {
            type: :array,
            items: {
              type: :string,
              uniqueItems: true,
            },
          },
        },
      }
    end

    def index_schema
      @index_schema ||= {
        type: :object,
        properties: {
          phrase: {
            type: :string,
          },
          condition: {
            type: :string,
            enum: Dictionary::CONDITION_LIST,
          },
          content: {
            type: :string,
          },
        },
      }
    end
  end
end
