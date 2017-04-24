# coding: utf-8
require 'rails_helper'

describe CategoriesController, :type => :controller do
  shared_context 'カテゴリを検索する' do |param = {}, app_auth_header = CommonHelper.app_auth_header|
    before(:all) do
      client.header('Authorization', app_auth_header)
      @res = client.get('/categories.json', param)
      @pbody = JSON.parse(@res.body) rescue nil
    end
  end

  include_context '事前準備: クライアントアプリを作成する'
  include_context '事前準備: 収支情報を登録する'

  describe '正常系' do
    [['algieba', 1], ['not_exist', 0]].each do |keyword, size|
      context "#{keyword}を指定した場合" do
        include_context 'カテゴリを検索する', {:keyword => keyword}

        it_behaves_like 'ステータスコードが正しいこと', '200'

        it "レスポンスボディの配列のサイズが#{size}であること" do
          expect(@pbody.size).to eq size
        end

        it "カテゴリ名が#{keyword}であること", :if => size > 0 do
          expect(@pbody.first['name']).to eq keyword
        end
      end
    end

    context 'keywordを指定しなかった場合' do
      include_context 'カテゴリを検索する'

      it_behaves_like 'ステータスコードが正しいこと', '200'

      it '全てのカテゴリ情報が取得されていること' do
        actual_categories = @pbody.map {|category| category['name'] }.sort
        expect(actual_categories).to eq Category.order(:name).pluck(:name)
      end
    end
  end

  describe '異常系' do
    context 'Authorizationヘッダーがない場合' do
      include_context 'カテゴリを検索する', {:keyword => 'algieba'}, nil
      it_behaves_like '400エラーをチェックする', ['absent_header']
    end

    context 'Authorizationヘッダーが不正な場合' do
      include_context 'カテゴリを検索する', {:keyword => 'algieba'}, 'invalid'
      it_behaves_like 'ステータスコードが正しいこと', '401'
    end
  end
end
