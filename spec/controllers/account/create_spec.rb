# coding: utf-8
require 'rails_helper'

describe AccountsController, :type => :controller do
  shared_context '家計簿を登録する' do |params|
    before(:all) do
      @res = @client.post('/accounts.json', params || @params)
      @pbody = JSON.parse(@res.body) rescue nil
    end
  end

  include_context 'Controller: 共通設定'

  context '正常系' do
    before(:all) { @params = {:accounts => @test_account[:income]} }
    after(:all) { Account.where(@test_account[:income].except(:id)).delete_all }

    include_context '家計簿を登録する'

    it_behaves_like 'ステータスコードが正しいこと', '201'

    it 'レスポンスの属性値が正しいこと' do
      actual_account = @pbody.slice(*@account_keys).symbolize_keys
      expected_account = @test_account[:income].except(:id)
      expect(actual_account).to eq expected_account
    end
  end

  context '異常系' do
    account_params = %i[ account_type date content category price ]
    test_cases = [].tap do |tests|
      (account_params.size - 1).times {|i| tests << account_params.combination(i + 1).to_a }
    end.flatten(1)

    test_cases.each do |deleted_keys|
      context "#{deleted_keys.join(',')}がない場合" do
        before(:all) do
          selected_keys = account_params - deleted_keys
          @params = {:accounts => @test_account[:income].slice(*selected_keys)}
        end

        include_context '家計簿を登録する'

        it_behaves_like '400エラーをチェックする', deleted_keys.map {|key| "absent_param_#{key}" }
      end
    end

    [nil, {}, {:accounts => nil}, {:accounts => {}}].each do |params|
      context 'accounts パラメーターがない場合' do
        include_context '家計簿を登録する', params
        it_behaves_like '400エラーをチェックする', ['absent_param_accounts']
      end
    end

    [
      {:account_type => 'invalid_type'},
      {:date => 'invalid_date'},
      {:price => 'invalid_price'},
      {:account_type => 'invalid_type', :date => 'invalid_date', :price => 'invalid_price'},
    ].each do |invalid_param|
      context "#{invalid_param.keys.join(',')}が不正な場合" do
        before(:all) { @params = {:accounts => @test_account[:expense].merge(invalid_param)} }
        include_context '家計簿を登録する'
        it_behaves_like '400エラーをチェックする', invalid_param.keys.map {|key| "invalid_param_#{key}" }
      end
    end
  end
end
