module Api
  class DictionariesController < ApplicationController
    def create
      begin
        attributes = params.permit(*create_params)
      rescue ActionController::ParameterMissing
        raise BadRequest, 'absent_param_payments'
      end

      absent_keys = create_params - attributes.symbolize_keys.keys
      error_codes = absent_keys.map {|key| "absent_param_#{key}" }
      raise BadRequest, error_codes unless absent_keys.empty?

      @dictionary = Dictionary.new(attributes.except(:categories))
      @dictionary.categories << attributes[:categories].map do |category_name|
        Category.find_or_create_by(name: category_name)
      end

      if @dictionary.save
        render status: :created, template: 'dictionaries/dictionary'
      else
        error_codes = @dictionary.errors.messages.keys.map {|key| "invalid_param_#{key}" }
        raise BadRequest, error_codes
      end
    end

    def index
      query = params.permit(*index_params)
      @dictionaries = if query.empty?
                        Dictionary.all
                      else
                        Dictionary.all.select do |dictionary|
                          query[:content].include?(dictionary.phrase)
                        end
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
