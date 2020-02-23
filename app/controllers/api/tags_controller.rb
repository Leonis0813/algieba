module Api
  class TagsController < ApplicationController
    before_action :check_request_tag

    def create
      check_absent_param(create_param, %i[name])
      unless create_param[:name].is_a?(String)
        raise BadRequest, 'invalid_param_name'
      end

      @tag = Tag.new(create_param)
      begin
        if @tag.save
          render status: :created, template: 'tags/tag'
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

    def assign_payments
      check_absent_param(assign_payments_param, %i[payment_ids])
      unless assign_payments_param[:payment_ids].is_a?(Array)
        raise BadRequest, 'invalid_param_payment_ids'
      end

      tag.payments += Payment.where(payment_id: assign_payments_param[:payment_ids])
      tag.save!
      render :ok, nothing: true
    end

    private

    def check_request_tag
      raise NotFound unless tag
    end

    def tag
      @tag ||= Tag.find_by(request.path_parameters.slice(:tag_id))
    end

    def create_param
      @create_param ||= request.request_parameters.slice(:name)
    end

    def assign_payments_param
      @assign_payments_param ||= request.request_parameters.slice(:payment_ids)
    end
  end
end
