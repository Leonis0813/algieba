# coding: utf-8

require 'rails_helper'

describe Api::PaymentsController, type: :controller do
  render_views

  describe '#show' do
    shared_context '収支情報を取得する' do |payment_id|
      before do
        payment_id ||= @payment.payment_id
        get(:show, params: {payment_id: payment_id}, format: :json)
        @response_status = response.status
        @response_body = JSON.parse(response.body) rescue response.body
      end
    end

    include_context 'トランザクション作成'
    before(:all) { @payment = create(:payment) }

    describe '正常系' do
      before(:all) do
        categories = @payment.categories.map do |category|
          category.slice(:category_id, :name, :description)
        end
        tags = @payment.tags.map {|tag| tag.slice(:tag_id, :name) }

        @body = @payment.slice(:payment_id, :payment_type, :content, :price).merge(
          date: @payment.date.strftime('%F'),
          categories: categories,
          tags: tags,
          ).deep_stringify_keys
      end
      include_context '収支情報を取得する'
      it_behaves_like 'レスポンスが正しいこと'
    end

    describe '異常系' do
      context '存在しないidを指定した場合' do
        include_context '収支情報を取得する', 'not_exist'
        it_behaves_like 'レスポンスが正しいこと', status: 404, body: ''
      end
    end
  end
end
