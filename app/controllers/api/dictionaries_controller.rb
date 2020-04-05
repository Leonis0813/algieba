module Api
  class DictionariesController < ApplicationController
    def create
      check_absent_param(create_params, %i[phrase condition categories])

      @dictionary = Dictionary.new(create_params.except(:categories))
      @dictionary.categories << create_params[:categories].map do |category_name|
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
      render status: :ok, template: 'dictionaries/dictionaries'
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
