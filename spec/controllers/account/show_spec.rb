# coding: utf-8
require 'rails_helper'

describe AccountsController, :type => :controller do
  include_context 'Controller: 共通設定'
  before(:all) { @test_account.each {|_, value| Account.create!(value) } }
  after(:all) { @test_account.each {|_, value| Account.find_by(value).delete } }

  context '正常系' do
    before(:all) do
      @id = @test_account[:income][:id]
      @expected_accounts = @test_account[:income]
    end
    include_context 'Controller: 家計簿を取得する'
    it_behaves_like 'Controller: 家計簿が正しく取得されていることを確認する'
  end

  context '異常系' do
    before(:all) { @id = 100 }
    include_context 'Controller: 家計簿を取得する'
    it_behaves_like '404エラーをチェックする'
  end
end
