# coding: utf-8
require 'rails_helper'

describe AccountsController, :type => :controller do
  shared_context '家計簿を削除する' do |id|
    before(:all) do
      @res = @client.delete("/accounts/#{id || @id}")
      @pbody = JSON.parse(@res.body) rescue nil
    end
  end

  include_context 'Controller: 共通設定'
  before(:all) { @test_account.each {|_, value| Account.create!(value) } }
  after(:all) { @test_account.each {|_, value| Account.find_by(value).try(:delete) } }

  context '正常系' do
    before(:all) { @id = @test_account[:income][:id] }
    include_context '家計簿を削除する'
    it_behaves_like 'ステータスコードが正しいこと', '204'
  end

  context '異常系' do
    include_context '家計簿を削除する', 100
    it_behaves_like 'ステータスコードが正しいこと', '404'
  end
end
