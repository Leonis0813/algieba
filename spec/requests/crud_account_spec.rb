# coding: utf-8
require 'rails_helper'

describe '家計簿を管理する', :type => :request do
  valid_account = {:account_type => 'expense', :date => '1000-01-01', :content => 'システムテスト用データ', :category => 'システムテスト', :price => 100}
  invalid_account = {:account_type => 'expense', :date => '01-01-1000', :category => 'システムテスト', :price => 100}

  include_context '共通設定'
  after(:all) { @hc.delete("#{@base_url}/accounts", {:category => 'システムテスト'}) }

  describe '家計簿を登録する' do
    include_context 'POST /accounts', invalid_account
    it_behaves_like '400エラーをチェックする', ['absent_param_content']
  end

  describe '家計簿を登録する' do
    include_context 'POST /accounts', valid_account
    it_behaves_like 'Request: 家計簿が正しく登録されていることを確認する'
  end

  describe '家計簿を検索する' do
    include_context 'GET /accounts', :content => 'システムテスト用データ'
    it_behaves_like 'Request: 家計簿が正しく検索されていることを確認する'
  end

  describe '家計簿を更新する' do
    include_context 'PUT /accounts', {:date => '1000-01-01'}, {:account_type => 'income'}
    it_behaves_like 'Request: 家計簿が正しく更新されていることを確認する'
  end

  describe '家計簿を検索する' do
    include_context 'GET /accounts', :account_type => 'income'
    it_behaves_like 'Request: 家計簿が正しく検索されていることを確認する'
  end

  describe '家計簿を削除する' do
    include_context 'DELETE /accounts', :category => 'システムテスト'
    it_behaves_like 'Request: 家計簿が正しく削除されていることを確認する'
  end

  describe '家計簿を検索する' do
    include_context 'GET /accounts', :price => 100
    it_behaves_like 'Request: 家計簿が正しく検索されていることを確認する'
  end
end
