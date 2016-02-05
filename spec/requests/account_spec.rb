# coding: utf-8
require 'rails_helper'

describe '家計簿を管理する', :type => :request do
  base_url = 'http://160.16.66.112:88'
  account = {
    :account_type => 'expense',
    :date => '1000-01-01',
    :content => 'システムテスト用データ',
    :category => 'システムテスト',
    :price => 100,
  }

  before(:all) { @hc = HTTPClient.new }
  after(:all) { @hc.delete("#{base_url}/accounts", {:category => 'システムテスト'}) }

  describe '家計簿を登録する' do
    before(:all) do
      invalid_account = {
        :account_type => 'expense',
        :date => '01-01-1000',
        :category => 'システムテスト',
        :price => 100,
      }
      @res = @hc.post("#{base_url}/accounts", {:accounts => invalid_account}.to_json, {'Content-Type' => 'application/json'})
      @pbody = JSON.parse(@res.body)
    end

    it 'ステータスコードが400であること' do
      expect(@res.code).to eq 400
    end

    it 'エラーコードの数が１つであること' do
      expect(@pbody.size).to eq 1
    end

    it 'エラーコードが正しいこと' do
      expect(@pbody).to eq [{'error_code' => 'absent_param_content'}]
    end
  end

  describe '家計簿を登録する' do
    before(:all) do
      @res = @hc.post("#{base_url}/accounts", {:accounts => account}.to_json, {'Content-Type' => 'application/json'})
      @pbody = JSON.parse(@res.body)
    end

    it 'ステータスコードが201であること' do
      expect(@res.code).to eq 201
    end

    %w[account_type date content category price].each do |key|
      it "レスポンスボディに#{key}が含まれていること" do
        expect(@pbody.keys).to include key
      end
    end
  end

  describe '家計簿を検索する' do
    before(:all) do
      @res = @hc.get("#{base_url}/accounts", {:content => 'システムテスト用データ'})
      @pbody = JSON.parse(@res.body)
    end

    it 'ステータスコードが200であること' do
      expect(@res.code).to eq 200
    end

    %w[account_type date content category price].each do |key|
      it "レスポンスボディに#{key}が含まれていること" do
        expect(@pbody.first.keys).to include key
      end
    end
  end

  describe '家計簿を更新する' do
    before(:all) do
      @res = @hc.put("#{base_url}/accounts", {:condition => {:date => '1000-01-01'}, :with => {:account_type => 'income'}}.to_json, {'Content-Type' => 'application/json'})
      @pbody = JSON.parse(@res.body)
    end

    it 'ステータスコードが200であること' do
      expect(@res.code).to eq 200
    end

    %w[account_type date content category price].each do |key|
      it "レスポンスボディに#{key}が含まれていること" do
        expect(@pbody.first.keys).to include key
      end
    end
  end

  describe '家計簿を検索する' do
    before(:all) do
      @res = @hc.get("#{base_url}/accounts", {:account_type => 'income'})
      @pbody = JSON.parse(@res.body)
    end

    it 'ステータスコードが200であること' do
      expect(@res.code).to eq 200
    end

    %w[account_type date content category price].each do |key|
      it "レスポンスボディに#{key}が含まれていること" do
        expect(@pbody.first.keys).to include key
      end
    end
  end

  describe '家計簿を削除する' do
    before(:all) { @res = @hc.delete("#{base_url}/accounts", {:category => 'システムテスト'}) }

    it 'ステータスコードが204であること' do
      expect(@res.code).to eq 204
    end
  end

  describe '家計簿を検索する' do
    before(:all) do
      @res = @hc.get("#{base_url}/accounts", {:price => 100})
      @pbody = JSON.parse(@res.body)
    end

    it 'ステータスコードが200であること' do
      expect(@res.code).to eq 200
    end

    it 'レスポンスボディが空であること' do
      expect(@pbody).to eq []
    end
  end
end

describe '収支を計算する', :type => :request do
  describe '家計簿を登録する' do

  end

  describe '家計簿を登録する' do

  end

  describe '家計簿を登録する' do

  end

  describe '家計簿を検索する' do

  end

  describe '収支を計算する' do

  end

  describe '収支を計算する' do

  end

  describe '収支を計算する' do

  end
end
