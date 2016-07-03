# coding: utf-8
require 'rails_helper'

describe AccountsController, :type => :controller do
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
        before(:all) do
          @test_account.each {|_, value| Account.create!(value) }
          @id = @test_account[updated_account][:id]
          @params = params
          @expected_account = @test_account[updated_account].merge(params).except(:id)
        end
        after(:all) { @test_account.each {|_, value| Account.find(value[:id]).delete } }
        include_context 'Controller: 家計簿を更新する'
        it_behaves_like 'Controller: 家計簿が正しく更新されていることを確認する'
      end
    end
  end

  context '異常系' do
    [
      ['不正な種類を指定する場合', :income, {:account_type => 'invalid_type'}],
      ['不正な日付を指定する場合', :income, {:date => '01-01-1000'}],
      ['不正な金額を指定する場合', :income, {:price => -1}],
      ['不正な種類，日付，金額で更新する場合', :income, {:account_type => 'invalid_type', :date => 'invalid_date', :price => 100.0}],
    ].each do |description, updated_account, params|
      context description do
        before(:all) do
          @test_account.each {|_, value| Account.create!(value) }
          @id = @test_account[updated_account][:id]
          @params = params
          @expected_account = @test_account[updated_account].merge(params).except(:id)
        end
        after(:all) { @test_account.each {|_, value| Account.find(value[:id]).delete } }
        include_context 'Controller: 家計簿を更新する'
        it_behaves_like '400エラーをチェックする', params.map {|key, _| "invalid_param_#{key}" }
      end
    end

    context '存在しないidを指定した場合' do
      before(:all) do
        @id = 100
        @params = {:account_type => 'expense'}
      end
      include_context 'Controller: 家計簿を更新する'
      it_behaves_like '404エラーをチェックする'
    end
  end
end
