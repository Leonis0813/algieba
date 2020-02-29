# coding: utf-8

require 'rails_helper'

describe Api::TagsController, type: :controller do
  shared_context 'タグを設定済みの収支情報を作成する' do
    before(:all) do
      @tag ||= create(:tag)
      @assigned_payment = create(:payment, tags: [])
      @tag.update!(payments: [@assigned_payment])
    end
  end

  shared_context 'タグを収支情報に設定する' do |tag_id: nil, request_body: nil|
    before(:all) do
      tag_id ||= @tag_id
      request_body ||= @request_body
      response = client.post("/api/tags/#{tag_id}/payments", request_body)
      @response_status = response.status
      @response_body = JSON.parse(response.body) rescue response.body
    end
  end

  shared_examples 'タグが収支情報に設定されていること' do
    it_is_asserted_by do
      @assigned_payments.all? do |payment|
        @tag.payments.where(payment_id: payment.payment_id).count == 1
      end
    end
  end

  shared_examples 'タグが収支情報に設定されていないこと' do |query|
    it_is_asserted_by do
      @not_assigned_payments.all? do |payment|
        not @tag.payments.exists?(payment_id: payment.payment_id)
      end
    end
  end

  describe '正常系' do
    context '設定済みのタグがない場合' do
      include_context 'トランザクション作成'
      before(:all) do
        @tag = create(:tag)
        @tag_id = @tag.tag_id
        payment = create(:payment, tags: [])
        @request_body = {payment_ids: [payment.payment_id]}
        @assigned_payments = [payment]
      end
      include_context 'タグを収支情報に設定する'

      it_behaves_like 'レスポンスが正しいこと', body: ''
      it_behaves_like 'タグが収支情報に設定されていること'
    end

    context '設定済みのタグがある場合' do
      include_context 'トランザクション作成'
      include_context 'タグを設定済みの収支情報を作成する'
      before(:all) do
        @tag_id = @tag.tag_id
        payment = create(:payment, tags: [])
        @assigned_payments = [@assigned_payment, payment]
        @request_body = {payment_ids: @assigned_payments.map(&:payment_id)}
      end
      include_context 'タグを収支情報に設定する'

      it_behaves_like 'レスポンスが正しいこと', body: ''
      it_behaves_like 'タグが収支情報に設定されていること'
    end
  end

  describe '異常系' do
    context '指定したタグが存在しない場合' do
      include_context 'トランザクション作成'
      before(:all) { @request_body = {payment_ids: [create(:payment).payment_id]} }
      include_context 'タグを収支情報に設定する', tag_id: 'not_exist'

      it_behaves_like 'レスポンスが正しいこと', status: 404, body: ''
    end

    %i[payment_ids].each do |absent_key|
      context "#{absent_key}がない場合" do
        body = {'errors' => [{'error_code' => "absent_param_#{absent_key}"}]}
        include_context 'トランザクション作成'
        include_context 'タグを設定済みの収支情報を作成する'
        before(:all) do
          @tag_id = @tag.tag_id
          @assigned_payments = [@assigned_payment]
        end
        include_context 'タグを収支情報に設定する', request_body: {}

        it_behaves_like 'レスポンスが正しいこと', status: 400, body: body
        it_behaves_like 'タグが収支情報に設定されていること'
      end
    end

    context 'payment_idsの型が不正な場合' do
      body = {'errors' => [{'error_code' => 'invalid_param_payment_ids'}]}
      include_context 'トランザクション作成'
      include_context 'タグを設定済みの収支情報を作成する'
      before(:all) do
        @tag_id = @tag.tag_id
        payment = create(:payment, tags: [])
        @request_body = {payment_ids: payment.payment_id}
        @assigned_payments = [@assigned_payment]
        @not_assigned_payments = [payment]
      end
      include_context 'タグを収支情報に設定する'

      it_behaves_like 'レスポンスが正しいこと', status: 400, body: body
      it_behaves_like 'タグが収支情報に設定されていること'
      it_behaves_like 'タグが収支情報に設定されていないこと'
    end

    context 'payment_idsに存在しない収支情報が含まれている場合' do
      body = {'errors' => [{'error_code' => 'invalid_param_payment_ids'}]}
      include_context 'トランザクション作成'
      include_context 'タグを設定済みの収支情報を作成する'
      before(:all) do
        @tag_id = @tag.tag_id
        payment = create(:payment, tags: [])
        @request_body = {payment_ids: ['not_exist', payment.payment_id]}
        @assigned_payments = [@assigned_payment]
        @not_assigned_payments = [payment]
      end
      include_context 'タグを収支情報に設定する'

      it_behaves_like 'レスポンスが正しいこと', status: 400, body: body
      it_behaves_like 'タグが収支情報に設定されていること'
      it_behaves_like 'タグが収支情報に設定されていないこと'
    end
  end
end
