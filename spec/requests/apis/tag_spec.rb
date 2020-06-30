# coding: utf-8

require 'rails_helper'

describe 'タグ情報APIのテスト', type: :request do
  payment = {
    payment_type: 'expense',
    date: '1000-01-01',
    content: 'システムテスト用データ',
    categories: ['algieba'],
    price: 100,
  }

  shared_examples 'タグ情報作成時のレスポンスが正しいこと' do |expected_body|
    it_behaves_like 'ステータスコードが正しいこと', 201

    it_is_asserted_by do
      @response_body.keys.sort == TagHelper.response_keys
    end

    expected_body.each do |key, value|
      it "#{key}が#{value}であること" do
        is_asserted_by { @response_body[key.to_s] == value }
      end
    end
  end

  before(:all) { @payment_ids = [] }
  include_context '収支情報を作成する', payment
  before(:all) { @payment_ids << @response_body['payment_id'] }
  include_context '収支情報を作成する', payment
  before(:all) { @payment_ids << @response_body['payment_id'] }

  after(:all) { delete_payments }

  describe 'タグ情報を作成する' do
    body = {name: SecureRandom.hex(5)}
    include_context 'タグ情報を作成する', body
    before(:all) { @tag_id = @response_body['tag_id'] }
    it_behaves_like 'タグ情報作成時のレスポンスが正しいこと', body
  end
end
