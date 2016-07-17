# coding: utf-8
require 'rails_helper'

describe AccountsController, :type => :controller do
  include_context 'Controller: 共通設定'

  context '正常系' do
    before(:all) do
      @params = {:accounts => @test_account[:income]}
      @expected_account = @test_account[:income].except(:id)
    end
    after(:all) { Account.where(@test_account[:income].except(:id)).map(&:delete) }
    include_context 'Controller: 家計簿を登録する'
    it_behaves_like 'Controller: 家計簿が正しく登録されていることを確認する'
  end

  context '異常系' do
    [
      ['種類がない場合', [:account_type]],
      ['日付がない場合', [:date]],
      ['内容がない場合', [:content]],
      ['カテゴリがない場合', [:category]],
      ['金額がない場合', [:price]],
      ['日付と金額がない場合', [:date, :price]],
    ].each do |description, deleted_keys|
      context description do
        before(:all) do
          selected_keys = @account_keys.map(&:to_sym) - deleted_keys
          @params = {:accounts => @test_account[:income].slice(*selected_keys)}
        end
        include_context 'Controller: 家計簿を登録する'
        it_behaves_like '400エラーをチェックする', deleted_keys.map {|key| "absent_param_#{key}" }
      end
    end

    [{}, {:accounts => {}}].each do |params|
      context 'accounts パラメーターがない場合' do
        before(:all) { @params = params }
        include_context 'Controller: 家計簿を登録する'
        it_behaves_like '400エラーをチェックする', ['absent_param_accounts']
      end
    end

    [
      ['不正な種類を指定する場合', {:account_type => 'invalid_type'}],
      ['不正な日付を指定する場合', {:date => 'invalid_date'}],
      ['不正な金額を指定する場合', {:price => 'invalid_price'}],
      ['不正な種類と金額を指定する場合', {:account_type => 'invalid_type', :price => 'invalid_price'}],
    ].each do |description, invalid_param|
      context description do
        before(:all) { @params = {:accounts => @test_account[:expense].merge(invalid_param)} }
        include_context 'Controller: 家計簿を登録する'
        it_behaves_like '400エラーをチェックする', invalid_param.keys.map {|key| "invalid_param_#{key}" }
      end
    end
  end
end
