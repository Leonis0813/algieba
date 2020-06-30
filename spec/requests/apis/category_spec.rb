# coding: utf-8

require 'rails_helper'

describe 'カテゴリ情報APIのテスト', type: :request do
  category_name = 'algieba'
  payment = {
    payment_type: 'expense',
    date: '1000-01-01',
    content: 'システムテスト用データ',
    categories: [category_name, 'other'],
    price: 100,
  }

  shared_examples 'カテゴリ検索時のレスポンスが正しいこと' do
    it_behaves_like 'ステータスコードが正しいこと', 200

    it_is_asserted_by { @response_body.keys.sort == %w[categories] }

    it do
      @response_body['categories'].each do |category|
        is_asserted_by { category.keys.sort == CategoryHelper.response_keys }
      end
    end
  end

  include_context '収支情報を作成する', payment

  after(:all) { delete_payments }

  describe 'カテゴリ情報を検索する' do
    include_context 'カテゴリ情報を検索する'
    it_behaves_like 'カテゴリ検索時のレスポンスが正しいこと'
  end

  describe 'keywordを指定してカテゴリ情報を検索する' do
    include_context 'カテゴリ情報を検索する', {keyword: category_name}
    it_behaves_like 'カテゴリ検索時のレスポンスが正しいこと'

    it "カテゴリ名が#{category_name}であること" do
      is_asserted_by do
        @response_body['categories'].all? do |category|
          category['name'] == category_name
        end
      end
    end
  end
end
