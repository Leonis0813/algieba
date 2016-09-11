# coding: utf-8
require 'rails_helper'

describe AccountsController, :type => :controller do
  shared_context '家計簿を更新する' do |id, params|
    before(:all) do
      @res = @client.put("/accounts/#{id || @id}.json", params || @params)
      @pbody = JSON.parse(@res.body) rescue nil
    end
  end

  include_context 'Controller: 共通設定'

  context '正常系' do
    [
      ['種類を更新する場合', :income, {:account_type => 'expense'}],
      ['内容を更新する場合', :income, {:content => '更新後データ'}],
      ['カテゴリを更新する場合', :income, {:category => 'updated'}],
      ['金額を更新する場合', :income, {:price => 1}],
      ['種類と日付を更新する場合', :income, {:account_type => 'expense', :date => '1000-02-01'}],
      ['内容とカテゴリを更新する場合', :income, {:content => '更新後データ', :category => 'updated'}],
      ['日付と金額を更新する場合', :income, {:date => '1000-01-02', :price => 1000}],
      ['全ての属性を更新する場合', :income, {:account_type => 'expense', :date => '1000-01-02', :content => '更新後データ', :category => 'updated', :price => 1}],
      ['更新しない場合', :income, {}],
    ].each do |description, updated_account, params|
      context description do
        include_context '事前準備: 家計簿を登録する'

        before(:all) do
          @id = @test_account[updated_account][:id]
          @expected_account = @test_account[updated_account].merge(params).except(:id)
        end

        include_context '家計簿を更新する', nil, params

        it_behaves_like 'ステータスコードが正しいこと', '200'

        it 'レスポンスの属性値が正しいこと' do
          actual_account = @pbody.slice(*@account_keys).symbolize_keys
          expect(actual_account).to eq @expected_account
        end
      end
    end
  end

  context '異常系' do
    [
      ['不正な種類を指定する場合', :income, {:account_type => 'invalid_type'}],
      ['不正な日付を指定する場合', :income, {:date => 'invalid_date'}],
      ['不正な金額を指定する場合', :income, {:price => -1}],
      ['不正な種類，日付，金額で更新する場合', :income, {:account_type => 'invalid_type', :date => 'invalid_date', :price => 100.0}],
    ].each do |description, updated_account, params|
      context description do
        include_context '事前準備: 家計簿を登録する'

        before(:all) do
          @id = @test_account[updated_account][:id]
          @expected_account = @test_account[updated_account].merge(params).except(:id)
        end

        include_context '家計簿を更新する', nil, params

        it_behaves_like '400エラーをチェックする', params.map {|key, _| "invalid_param_#{key}" }
      end
    end

    context '存在しないidを指定した場合' do
      include_context '家計簿を更新する', 100, {:account_type => 'expense'}
      it_behaves_like 'ステータスコードが正しいこと', '404'
    end
  end
end
