# coding: utf-8

require 'rails_helper'

describe 'タグ管理画面のテスト', type: :request do
  new_tag_name = Time.now.to_i.to_s
  content = 'システムテスト用データ'

  shared_context '登録前の件数を確認する' do
    before(:all) do
      element = @wait.until do
        @driver.find_element(:xpath, '//div[@class="col-lg-8"]/div/h4')
      end
      @before_total_count = element.text.match(/(.*)件中/)[1].to_i
    end
  end

  shared_examples '登録に成功していること' do
    it '件数が増えていること' do
      element = @wait.until do
        @driver.find_element(:xpath, '//div[@class="col-lg-8"]/div/h4')
      end
      after_total_count = element.text.match(/(.*)件中/)[1].to_i

      is_asserted_by { after_total_count == @before_total_count + 1 }
    end
  end

  shared_examples '入力フォームが全て空であること' do
    it_is_asserted_by { @driver.find_element(:id, 'name').text == '' }
  end

  before(:all) { delete_payments }
  after(:all) { delete_payments }

  body = {
    payment_type: 'expense',
    date: '1000-01-01',
    content: content,
    categories: ['test'],
    price: 100,
  }
  include_context '収支情報を作成する', body
  include_context 'Webdriverを起動する'
  include_context 'Cookieをセットする'

  before(:all) do
    @driver.get(base_url)
    @wait.until do
      res = @driver.find_element(:xpath, '//li/a[text()="タグ"]').click rescue false
      res.nil?
    end
  end

  describe 'タグ情報を登録する' do
    include_context '登録前の件数を確認する'
    before(:all) do
      name_input = @wait.until { @driver.find_element(:id, 'name') }
      name_input.clear
      name_input.send_keys(new_tag_name)
      @wait.until do
        res = @driver.find_element(:id, 'btn-tag-create').click rescue false
        res.nil?
      end
    end

    it_behaves_like '登録に成功していること'
    it_behaves_like '入力フォームが全て空であること'
  end

  describe 'タグ情報を検索する' do
    before(:all) do
      @wait.until do
        res = @driver.find_element(:xpath, '//li/a[@href="#search-form"]').click rescue false
        res.nil?
      end
      name_input = @wait.until { @driver.find_element(:id, 'name_include') }
      name_input.clear
      name_input.send_keys(new_tag_name)
      @wait.until do
        res = @driver.find_element(:id, 'btn-tag-search').click rescue false
        res.nil?
      end
    end

    it '件数情報が正しいこと' do
      element = @wait.until do
        @driver.find_element(:xpath, '//div[@class="col-lg-8"]/div/h4')
      end
      is_asserted_by { element.text.strip == '1件中1〜1件を表示' }
    end

    it 'テーブルに検索結果が表示されていること' do
      name = @wait.until { @driver.find_element(:xpath, '//td[@class="name"]') }

      is_asserted_by { name.present? }
      is_asserted_by { name.text.strip == new_tag_name }
    end
  end
end
