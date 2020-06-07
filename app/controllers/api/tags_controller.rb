module Api
  class TagsController < ApplicationController
    def create
      @tag = Tag.new(create_param)
      raise BadRequest, @tag.errors.messages, 'tag' unless @tag.save

      render status: :created
    end

    private

    def create_param
      @create_param ||= request.request_parameters.slice(:name)
    end
  end
end
