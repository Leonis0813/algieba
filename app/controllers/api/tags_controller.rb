module Api
  class TagsController < ApplicationController
    def create
      @tag = Tag.new(create_param)

      if @tag.save
        render status: :created
      else
        raise BadRequest, @tag.errors.messages, 'tag'
      end
    end

    private

    def create_param
      @create_param ||= request.request_parameters.slice(:name)
    end
  end
end
