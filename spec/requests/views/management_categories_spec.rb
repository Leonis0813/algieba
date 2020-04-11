# coding: utf-8

require 'rails_helper'

describe 'カテゴリ管理画面のテスト', type: :request do
  before(:all) { delete_payments }
  after(:all) { delete_payments }

  body = {payment_type: 'expense', date: '1000-01-01', content: 'テスト', price: 100}
  2.times do |i|
    include_context '収支情報を作成する', body.merge(categories: ["テスト#{i}"])
  end
  include_context 'Webdriverを起動する'
  include_context 'Cookieをセットする'

  before(:all) do
    @driver.get(base_url)
    @wait.until do
      res = @driver.find_element(:xpath, '//li/a[text()="カテゴリ"]').click rescue false
      res.nil?
    end
  end

  describe 'カテゴリ情報を検索する' do
    before(:all) do
      form = @wait.until { @driver.find_element(:id, 'name_include') }
      form.clear
      form.send_keys('1')
      @wait.until do
        res = @driver.find_element(:id, 'btn-category-search').click rescue false
        res.nil?
      end
    end

    it 'テーブルに検索結果が表示されていること' do
      names = @driver.find_elements(:xpath, '//td[@class="name"]')
      is_asserted_by { names.all? {|name| name.text.strip.include?('1') } }
    end
  end
end
