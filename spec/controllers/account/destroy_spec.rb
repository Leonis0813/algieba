# coding: utf-8
require 'rails_helper'

describe AccountsController, :type => :controller do
  include_context 'Controller: 共通設定'
    before(:all) do
    @ids = [].tap do |arr|
      @test_account.each do |_, value|
        res = @client.post('/accounts', {:accounts => value})
        arr << JSON.parse(res.body)['id']
      end
    end
  end
  after(:all) { @test_account.each {|_, value| Account.find_by(value).try(:delete) } }

  context '正常系' do
    before(:all) { @id = @ids.first }
    include_context 'Controller: 家計簿を削除する'
    it_behaves_like 'Controller: 家計簿が正しく削除されていることを確認する'
  end

  context '異常系' do
    before(:all) { @id = (@ids.first.to_i + @ids.last.to_i).to_s }
    include_context 'Controller: 家計簿を削除する'
    it_behaves_like '404エラーをチェックする'
  end
end
