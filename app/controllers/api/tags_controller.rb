module Api
  class TagsController < ApplicationController
    before_action :check_request_tag

    def assign_payments
      check_absent_param(assign_payments_param, %i[payment_ids])
      unless assign_payments_param[:payment_ids].kind_of?(Array)
        raise BadRequest, 'invalid_param_payment_ids'
      end

      tag.payments += Payment.where(:payment_id => assign_payments_param[:payment_ids])
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

    def assign_payments_param
      @assign_payments_param ||= request.request_parameters.slice(:payment_ids)
    end
  end
end
