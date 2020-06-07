module Api
  class DictionariesController < ApplicationController
    def create
      @dictionary = Dictionary.new(create_params.except(:categories))
      @dictionary.categories << Array.wrap(create_params[:categories]).map do |name|
        Category.find_or_initialize_by(name: name)
      end

      if @dictionary.save
        render status: :created
      else
        raise BadRequest, @dictionary, 'dictionary'
      end
    end

    def index
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
  end
end
