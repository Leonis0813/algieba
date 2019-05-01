# coding: utf-8
require 'rails_helper'

describe Api::CategoriesController, type: :controller do
  shared_context 'カテゴリを検索する' do |param = {}|
    before(:all) do
      @res = client.get('/api/categories', param)
      @pbody = JSON.parse(@res.body) rescue nil
    end
  end

  include_context '事前準備: 収支情報を登録する'

  describe '正常系' do
    [['algieba', 1], ['not_exist', 0]].each do |keyword, size|
      context "#{keyword}を指定した場合" do
        include_context 'カテゴリを検索する', {keyword: keyword}

        it_behaves_like 'ステータスコードが正しいこと', '200'

        it "レスポンスボディの配列のサイズが#{size}であること" do
          is_asserted_by { @pbody.size == size }
        end

        it "カテゴリ名が#{keyword}であること", if: size > 0 do
          is_asserted_by { @pbody.first['name'] == keyword }
        end
      end
    end

    context 'keywordを指定しなかった場合' do
      include_context 'カテゴリを検索する'

      it_behaves_like 'ステータスコードが正しいこと', '200'

      it '全てのカテゴリ情報が取得されていること' do
        actual_categories = @pbody.map {|category| category['name'] }.sort
        is_asserted_by { actual_categories == Category.order(:name).pluck(:name) }
      end
    end
  end
end
