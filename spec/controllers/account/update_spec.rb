# coding: utf-8
require 'rails_helper'

describe AccountsController, :type => :controller do
  shared_context '家計簿を更新する' do |id, params = {}|
    before(:all) do
      @res = client.put("/accounts/#{id}.json", params)
      @pbody = JSON.parse(@res.body) rescue nil
    end
  end

  include_context '事前準備: クライアントアプリを作成する'

  describe '正常系' do
    [
      {:account_type => 'expense'},
      {:date => '1000-01-02'},
      {:content => '更新後データ'},
      {:category => 'updated'},
      {:price => 1},
      {:account_type => 'expense', :date => '1000-01-02', :content => '更新後データ', :category => 'updated', :price => 1},
      {},
    ].each do |params|
      description = params.empty? ? '更新しない場合' : "#{params.keys.join(',')}を更新する場合"

      context description do
        include_context '事前準備: 家計簿を登録する'
        before(:all) { client.header('Authorization', app_auth_header) }
        include_context '家計簿を更新する', CommonHelper.test_account[:income][:id], params

        it_behaves_like 'ステータスコードが正しいこと', '200'

        it 'レスポンスの属性値が正しいこと' do
          actual_account = @pbody.slice(*account_params).symbolize_keys
          expected_account = test_account[:income].merge(params).except(:id)
          expect(actual_account).to eq expected_account
        end
      end
    end
  end

  describe '異常系' do
    context 'Authorizationヘッダーがない場合' do
      before(:all) { client.header('Authorization', nil) }
      include_context '家計簿を更新する', CommonHelper.test_account[:income][:id]
      it_behaves_like '400エラーをチェックする', ['absent_header']
    end

    [
      {:account_type => 'invalid_type'},
      {:date => 'invalid_date'},
      {:price => 'invalid_price'},
      {:account_type => 'invalid_type', :date => 'invalid_date', :price => 'invalid_price'},
    ].each do |params|
      context "#{params.keys.join(',')}が不正な場合" do
        include_context '事前準備: 家計簿を登録する'
        include_context '家計簿を更新する', CommonHelper.test_account[:income][:id], params
        it_behaves_like '400エラーをチェックする', params.map {|key, _| "invalid_param_#{key}" }
      end
    end

    context '存在しないidを指定した場合' do
      include_context '家計簿を更新する', 100, {:account_type => 'expense'}
      it_behaves_like 'ステータスコードが正しいこと', '404'
    end
  end
end
