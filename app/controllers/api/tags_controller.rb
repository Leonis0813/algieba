module Api
  class TagsController < ApplicationController
    def create
      check_absent_param(create_param, %i[name])
      raise BadRequest, 'invalid_param_name' unless create_param[:name].is_a?(String)

      @tag = Tag.new(create_param)
      begin
        if @tag.save
          render status: :created
        else
          error_codes = @tag.errors.messages.keys.map do |key|
            "invalid_param_#{key}"
          end
          raise BadRequest, error_codes
        end
      rescue ActiveRecord::RecordNotUnique
        raise Duplicated, 'tag'
      end
    end

    private

    def create_param
      @create_param ||= request.request_parameters.slice(:name)
    end
  end
end
