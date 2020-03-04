# coding: utf-8

require 'rails_helper'

describe 'ブラウザから収支を検索する', type: :request do
  per_page = Kaminari.config.default_per_page
  default_inputs = {
    date: '1000-01-01',
    content: 'regist from view',
    categories: ['テスト'],
    price: 100,
  }

  shared_examples 'フォームに値がセットされていること' do |attribute|
    it_is_asserted_by do
      xpath = "//input[@name='#{attribute[:name]}'][@value='#{attribute[:value]}']"
      @driver.find_element(:xpath, xpath)
    end
  end

  before(:all) do
    payment = default_inputs.merge(payment_type: 'income', categories: ['テスト'])

    header = app_auth_header.merge(content_type_json)
    (per_page + 1).times do
      body = payment.merge(price: rand(100)).to_json
      http_client.post("#{base_url}/api/payments", body, header)
    end
  end

  after(:all) { delete_payments }

  include_context 'Webdriverを起動する'
  include_context 'Cookieをセットする'

  describe '管理画面を開く' do
    before(:all) { @driver.get("#{base_url}/payments") }

    it '日付でソートされていること' do
      is_asserted_by { @driver.find_element(:class, 'sorting_desc').text == '日付' }
    end
  end

  describe '不正な金額を入力して検索する' do
    before(:all) do
      @driver.find_element(:xpath, '//a[@href="#search-form"]').click
      @driver.find_element(:name, 'price_upper').send_keys('invalid')
      @driver.find_element(:id, 'btn-payment-search').click
      @wait.until { @driver.find_element(:class, 'bootbox-alert').displayed? }
    end

    after(:all) do
      button = @wait.until { @driver.find_element(:xpath, '//div/button[text()="OK"]') }
      button.click
      @wait.until { @driver.find_element(:class, 'bootbox-alert') rescue true }
      @driver.find_element(:name, 'price_upper').clear
    end

    it_behaves_like '正しくエラーダイアログが表示されていること',
                    message: '金額 が不正です'
  end

  describe '10000円以下の収支情報を検索する' do
    before(:all) do
      @wait.until do
        res =
          @driver.find_element(:xpath, '//a[@href="#search-form"]').click rescue false
        res.nil? ? true : false
      end
      @driver.find_element(:name, 'price_lower').send_keys('10000')
      @driver.find_element(:id, 'btn-payment-search').click
      @wait.until { @driver.current_url.include?('price_lower=10000') }
    end

    it_behaves_like '表示されている件数が正しいこと', per_page + 1, 1, per_page
    it_behaves_like '収支情報の数が正しいこと', per_page
    it_behaves_like 'フォームに値がセットされていること',
                    name: 'price_lower', value: '10000'
  end

  describe '金額でソートする' do
    before(:all) { @driver.find_element(:xpath, '//th[text()="金額"]').click }

    it '金額でソートされていること' do
      is_asserted_by { @driver.find_element(:class, 'sorting_asc').text == '金額' }
    end

    it '収支情報がソートされていること' do
      prices = @driver.find_elements(:class, 'sorting_1').map(&:text).map(&:to_i)
      is_asserted_by { prices == prices.sort }
    end
  end

  describe '不正な表示件数を入力する' do
    before(:all) do
      @driver.find_element(:id, 'per_page').send_keys('invalid')
      @driver.find_element(:id, 'per_page').submit
      @wait.until { @driver.find_element(:class, 'bootbox-alert').displayed? }
    end

    after(:all) do
      button = @wait.until { @driver.find_element(:xpath, '//div/button[text()="OK"]') }
      button.click
      @wait.until { @driver.find_element(:class, 'bootbox-alert') rescue true }
    end

    it_behaves_like '正しくエラーダイアログが表示されていること',
                    message: '表示件数には数値を入力してください'

    it '表示件数が空文字になっていること' do
      is_asserted_by { @driver.find_element(:id, 'per_page').text.empty? }
    end
  end

  describe '表示件数を変更する' do
    before(:all) do
      @driver.find_element(:id, 'per_page').send_keys('20')
      @driver.find_element(:id, 'per_page').submit
      @wait.until { @driver.current_url.include?('per_page=20') }
    end

    it_behaves_like '表示されている件数が正しいこと', per_page + 1, 1, 20
    it_behaves_like '収支情報の数が正しいこと', 20
    it_behaves_like 'フォームに値がセットされていること',
                    name: 'price_lower', value: '10000'
    it_behaves_like 'フォームに値がセットされていること', name: 'per_page', value: '20'
  end

  describe '1000円以上10000円以下の収支情報を検索する' do
    before(:all) do
      @wait.until do
        res =
          @driver.find_element(:xpath, '//a[@href="#search-form"]').click rescue false
        res.nil? ? true : false
      end
      @driver.find_element(:name, 'price_upper').send_keys('1000')
      @driver.find_element(:id, 'btn-payment-search').click
      @wait.until { @driver.current_url.include?('price_upper=1000') }
    end

    it_behaves_like '表示されている件数が正しいこと', 0, 0, 0
    it_behaves_like 'フォームに値がセットされていること',
                    name: 'price_lower', value: '10000'
    it_behaves_like 'フォームに値がセットされていること',
                    name: 'price_upper', value: '1000'

    it 'テーブルにメッセージが表示されていること' do
      text = 'No data available in table'
      is_asserted_by do
        @wait.until { @driver.find_element(:xpath, '//td').text == text }
      end
    end
  end

  describe 'テスト，または新カテゴリの収支情報を検索する' do
    before(:all) do
      @wait.until do
        res =
          @driver.find_element(:xpath, '//a[@href="#search-form"]').click rescue false
        res.nil? ? true : false
      end
      @driver.find_element(:name, 'price_upper').clear
      @driver.find_element(:name, 'price_lower').clear
      @driver.find_element(:name, 'category').send_keys('テスト,新カテゴリ')
      @driver.find_element(:id, 'btn-payment-search').click
      @wait.until do
        CGI.unescape(@driver.current_url).include?('category=テスト,新カテゴリ')
      end
    end

    it_behaves_like '表示されている件数が正しいこと', per_page + 1, 1, 20
    it_behaves_like '収支情報の数が正しいこと', 20
    it_behaves_like 'フォームに値がセットされていること',
                    name: 'category', value: 'テスト,新カテゴリ'
  end

  describe 'カレンダーを表示する' do
    before(:all) do
      @wait.until do
        res =
          @driver.find_element(:xpath, '//a[@href="#search-form"]').click rescue false
        res.nil? ? true : false
      end
      @driver.find_element(:id, 'query_date_after').click
    end

    it 'カレンダーが表示されていること' do
      is_asserted_by { @driver.find_element(:class, 'bootstrap-datetimepicker-widget') }
    end
  end
end
