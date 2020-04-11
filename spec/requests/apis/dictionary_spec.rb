# coding: utf-8

require 'rails_helper'

describe '辞書情報APIのテスト', type: :request do
  content = "システムテスト用データ_#{Time.now.to_i}"
  payment = {
    payment_type: 'expense',
    date: '1000-01-01',
    content: content,
    categories: ['algieba'],
    price: 100,
  }

  shared_context '辞書情報を作成する' do |body|
    before(:all) do
      header = app_auth_header.merge(content_type_json)
      res = http_client.post("#{base_url}/api/dictionaries", body.to_json, header)
      @response_status = res.status
      @response_body = JSON.parse(res.body) rescue res.body
    end
  end

  shared_context '辞書情報を検索する' do |query|
    before(:all) do
      res = http_client.get("#{base_url}/api/dictionaries", query, app_auth_header)
      @response_status = res.status
      @response_body = JSON.parse(res.body) rescue res.body
    end
  end

  shared_examples '辞書情報作成時のレスポンスが正しいこと' do |expected_body|
    it_behaves_like 'ステータスコードが正しいこと', 201

    it_is_asserted_by do
      @response_body.keys.sort == DictionaryHelper.response_keys
    end

    expected_body.each do |key, value|
      it "#{key}が#{value}であること" do
        is_asserted_by { @response_body[key.to_s] == value }
      end
    end
  end

  shared_examples '辞書情報検索時のレスポンスが正しいこと' do |expected_phrases = []|
    it_behaves_like 'ステータスコードが正しいこと', 200

    it_is_asserted_by { @response_body.keys.sort == %w[dictionaries] }

    it do
      @response_body['dictionaries'].each do |dictionary|
        is_asserted_by { dictionary.keys.sort == DictionaryHelper.response_keys }
      end
    end

    expected_phrases.each do |phrase|
      it "phraseが#{phrase}の辞書が含まれていること" do
        is_asserted_by do
          @response_body['dictionaries'].any? do |dictionary|
            dictionary['phrase'] == phrase
          end
        end
      end
    end
  end

  include_context '収支情報を作成する', payment

  after(:all) { delete_payments }

  describe '辞書情報を作成する' do
    body = {phrase: content, condition: 'equal', categories: ['algieba']}
    include_context '辞書情報を作成する', body
    it_behaves_like '辞書情報作成時のレスポンスが正しいこと', body.except(:categories)
  end

  describe '辞書情報を作成する' do
    body = {phrase: content[1..-1], condition: 'include', categories: ['algieba']}
    include_context '辞書情報を作成する', body
    it_behaves_like '辞書情報作成時のレスポンスが正しいこと', body.except(:categories)
  end

  describe '辞書情報を検索する' do
    include_context '辞書情報を検索する'
    it_behaves_like '辞書情報検索時のレスポンスが正しいこと'
  end

  describe 'contentを指定して辞書情報を検索する' do
    include_context '辞書情報を検索する', {content: content}
    it_behaves_like '辞書情報検索時のレスポンスが正しいこと', [content, content[1..-1]]
  end

  describe 'phraseを指定して辞書情報を検索する' do
    include_context '辞書情報を検索する', {phrase: content}
    it_behaves_like '辞書情報検索時のレスポンスが正しいこと', [content]
  end

  describe 'conditionを指定して辞書情報を検索する' do
    include_context '辞書情報を検索する', {condition: 'include'}
    it_behaves_like '辞書情報検索時のレスポンスが正しいこと', [content[1..-1]]
  end

  describe 'phrase,conditionを指定して辞書情報を検索する' do
    include_context '辞書情報を検索する', {phrase: content, condition: 'equal'}
    it_behaves_like '辞書情報検索時のレスポンスが正しいこと', [content]
  end
end
