module Api
  class TagsController < ApplicationController
    def create
      check_schema(create_schema, create_param, resource: 'tag')

      @tag = Tag.new(create_param)
      raise BadRequest, messages: @tag.errors.messages, resource: 'tag' unless @tag.save

      render status: :created
    end

    private

    def create_param
      @create_param ||= request.request_parameters.slice(:name)
    end

    def create_schema
      @create_schema ||= {
        type: :object,
        required: %i[name],
        properties: {
          name: {type: :string, minLength: 1, maxLength: 10},
        },
      }
    end
  end
end
