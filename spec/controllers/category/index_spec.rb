# coding: utf-8
require 'rails_helper'

describe CategoriesController, :type => :controller do
  shared_context 'カテゴリを検索する' do |keyword = ''|
    before(:all) do
      client.header('Authorization', app_auth_header)
      @res = client.get('/categories.json', 'keyword' => keyword)
      @pbody = JSON.parse(@res.body) rescue nil
    end
  end

  include_context '事前準備: クライアントアプリを作成する'
  include_context '事前準備: 家計簿を登録する'

  describe '正常系' do
    context 'keywordを指定した場合', :wip do
      include_context 'カテゴリを検索する', 'algieba'
      it '' do
        p @pbody
      end
    end

    context 'keywordを指定しなかった場合' do
      include_context 'カテゴリを検索する'
    end
  end

  describe '異常系' do
    context 'Authorizationヘッダーがない場合' do

    end
  end
end
