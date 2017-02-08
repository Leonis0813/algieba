# coding: utf-8
require 'rails_helper'

describe PaymentsController, :type => :controller do
  shared_context '家計簿を更新する' do |id, params = {}, app_auth_header = CommonHelper.app_auth_header|
    before(:all) do
      client.header('Authorization', app_auth_header)
      @res = client.put("/payments/#{id}.json", params)
      @pbody = JSON.parse(@res.body) rescue nil
    end
  end

  include_context '事前準備: クライアントアプリを作成する'

  describe '正常系' do
    [
      {:payment_type => 'expense'},
      {:date => '1000-01-02'},
      {:content => '更新後データ'},
      {:category => 'updated'},
      {:price => 1},
      {
        :payment_type => 'expense',
        :date => '1000-01-02',
        :content => '更新後データ',
        :category => 'updated',
        :price => 1,
      },
      {},
    ].each do |params|
      description = params.empty? ? '更新しない場合' : "#{params.keys.join(',')}を更新する場合"

      context description do
        include_context '事前準備: 家計簿を登録する'
        include_context '家計簿を更新する', PaymentHelper.test_payment[:income][:id], params

        it_behaves_like 'ステータスコードが正しいこと', '200'

        it 'レスポンスの属性値が正しいこと' do
          actual_payment = @pbody.slice(*payment_params).symbolize_keys
          expected_payment = test_payment[:income].merge(params).except(:id)
          expect(actual_payment).to eq expected_payment
        end
      end
    end
  end

  describe '異常系' do
    context 'Authorizationヘッダーがない場合' do
      include_context '家計簿を更新する', PaymentHelper.test_payment[:income][:id], {}, nil
      it_behaves_like '400エラーをチェックする', ['absent_header']
    end

    [
      {:payment_type => 'invalid_type'},
      {:date => 'invalid_date'},
      {:price => 'invalid_price'},
      {:payment_type => 'invalid_type', :date => 'invalid_date', :price => 'invalid_price'},
    ].each do |params|
      context "#{params.keys.join(',')}が不正な場合" do
        include_context '事前準備: 家計簿を登録する'
        include_context '家計簿を更新する', PaymentHelper.test_payment[:income][:id], params
        it_behaves_like '400エラーをチェックする', params.map {|key, _| "invalid_param_#{key}" }
      end
    end

    context '存在しないidを指定した場合' do
      include_context '家計簿を更新する', 100, {:payment_type => 'expense'}
      it_behaves_like 'ステータスコードが正しいこと', '404'
    end
  end
end