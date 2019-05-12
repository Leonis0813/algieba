# coding: utf-8

require 'rails_helper'

describe 'ブラウザから操作する', type: :request do
  per_page = Kaminari.config.default_per_page
  default_inputs = {
    date: '1000-01-01',
    content: 'regist from view',
    categories: 'テスト',
    price: 100,
  }

  shared_context '収支情報を入力する' do |inputs, payment_type|
    before(:all) do
      @wait.until { @driver.find_element(:id, 'payments_date').displayed? }
      inputs.except(:categories).each do |key, value|
        element = @driver.find_element(:id, "payments_#{key}")
        element.clear
        element.send_keys(value.to_s)
      end
      xpath = '//form[@id="new_payments"]//span[@class="category-list"]/button'
      @driver.find_element(:xpath, xpath).click

      xpath = "//div[@class='modal-dialog']//input[@value='#{inputs[:categories]}']"
      @wait.until do
        @driver.find_element(:xpath, xpath).selected? ||
          (@driver.find_element(:xpath, xpath).click rescue false)
      end

      xpath = '//button[@data-bb-handler="confirm"]'
      @wait.until { @driver.find_element(:xpath, xpath).click rescue false }

      xpath = '//h4[text()="カテゴリを選択してください"]'
      @wait.until { (not @driver.find_element(:xpath, xpath).displayed?) rescue true }

      id = "payments_payment_type_#{payment_type}"
      @wait.until { @driver.find_element(:id, id).click rescue false }
    end
  end

  shared_context '登録ボタンを押す' do
    before(:all) do
      @wait.until do
        @driver.find_element(:xpath, '//form/input[@value="登録"]').click rescue false
      end
    end
  end

  shared_examples '入力フォームが全て空であること' do
    %w[date content categories price].each do |column|
      it_is_asserted_by { @driver.find_element(:id, "payments_#{column}").text == '' }
    end
  end

  shared_examples '正しくエラーダイアログが表示されていること' do |message: ''|
    alert_xpath = '//div[contains(@class, "bootbox-alert")]'

    it 'タイトルが正しいこと' do
      xpath = "#{alert_xpath}//h4"
      is_asserted_by { @driver.find_element(:xpath, xpath).text == 'エラー' }
    end

    it 'メッセージが正しいこと' do
      xpath = "#{alert_xpath}//div[contains(@class, 'alert-danger')]"
      is_asserted_by { @driver.find_element(:xpath, xpath).text == message }
    end

    it 'OKボタンがあること' do
      xpath = "#{alert_xpath}//div[@class='modal-footer']/button"
      is_asserted_by { @driver.find_element(:xpath, xpath).text == 'OK' }
    end
  end

  shared_examples '表示されている件数が正しいこと' do |total, from, to|
    it_is_asserted_by do
      text = "#{total}件中#{from}〜#{to}件を表示"
      @wait.until { @driver.find_element(:xpath, '//div/h4').text == text }
    end
  end

  shared_examples '収支情報の数が正しいこと' do |expected_size|
    it_is_asserted_by do
      @driver.find_elements(:xpath, '//table/tbody/tr').size == expected_size
    end
  end

  shared_examples 'フォームに値がセットされていること' do |attribute|
    it_is_asserted_by do
      xpath = "//input[@name='#{attribute[:name]}'][@value='#{attribute[:value]}']"
      @driver.find_element(:xpath, xpath)
    end
  end

  before(:all) do
    header = {'Authorization' => app_auth_header}
    res = http_client.get("#{base_url}/api/payments", nil, header)
    size = JSON.parse(res.body).size
    payment = default_inputs.merge(payment_type: 'income', category: 'テスト')

    header = {'Authorization' => app_auth_header}.merge(content_type_json)
    (per_page - 1 - size).times do
      body = {payments: payment.merge(price: rand(100))}.to_json
      http_client.post("#{base_url}/api/payments", body, header)
    end
  end

  after(:all) do
    query = {:per_page => 100}
    header = {'Authorization' => app_auth_header}
    res = http_client.get("#{base_url}/api/payments", query, header)
    payments = JSON.parse(res.body)
    payments.each do |payment|
      http_client.delete("#{base_url}/api/payments/#{payment['id']}", nil, header)
    end
  end

  include_context 'Webdriverを起動する'
  include_context 'Cookieをセットする'

  describe '管理画面を開く' do
    before(:all) { @driver.get("#{base_url}/payments") }

    it '日付でソートされていること' do
      is_asserted_by { @driver.find_element(:class, 'sorting_desc').text == '日付' }
    end
  end

  describe '不正な収支情報を登録する' do
    inputs = default_inputs.merge(price: 'invalid_price')
    include_context '収支情報を入力する', inputs, 'income'
    include_context '登録ボタンを押す'
    before(:all) do
      @wait.until { @driver.find_element(:class, 'modal-body').displayed? }
    end

    after(:all) do
      @wait.until do
        @driver.find_element(:xpath, '//div/button[text()="OK"]').click rescue false
      end
    end

    it_behaves_like '正しくエラーダイアログが表示されていること',
                    message: '金額 が不正です'
    it_behaves_like '収支情報の数が正しいこと', per_page - 1
  end

  describe '収支情報を登録する' do
    before(:all) do
      @wait.until { @driver.find_element(:id, 'payments_price').enabled? rescue false }
      element = @driver.find_element(:id, 'payments_price')
      element.clear
      element.send_keys('100')
    end
    include_context '登録ボタンを押す'

    it_behaves_like '表示されている件数が正しいこと', per_page, 1, per_page
    it_behaves_like '収支情報の数が正しいこと', per_page
  end

  describe 'カレンダーを表示する' do
    before(:all) do
      @wait.until { @driver.find_element(:id, 'payments_date').displayed? }
      @driver.find_element(:id, 'payments_date').click
    end

    it 'カレンダーが表示されていること' do
      is_asserted_by { @driver.find_element(:class, 'bootstrap-datetimepicker-widget') }
    end
  end

  describe '新しいカテゴリで収支情報を登録する' do
    include_context '収支情報を入力する', default_inputs.except, 'income'
    before(:all) do
      element = @driver.find_element(:id, 'payments_categories')
      element.clear
      element.send_keys('新カテゴリ')
    end
    include_context '登録ボタンを押す'

    it_behaves_like '表示されている件数が正しいこと', per_page + 1, 1, per_page
    it_behaves_like '収支情報の数が正しいこと', per_page
  end

  describe 'カテゴリ一覧を確認する' do
    before(:all) do
      @driver.find_element(:xpath, '//form//span[@class="category-list"]/button').click
      @wait.until { @driver.find_element(:class, 'bootbox-prompt').displayed? }
    end

    after(:all) do
      xpath = '//div[contains(@class, "bootbox-prompt")]//button[text()="Cancel"]'
      cancel_button = @wait.until { @driver.find_element(:xpath, xpath) }
      cancel_button.click
      @wait.until { @driver.find_element(:xpath, xpath) rescue true }
    end

    it '新カテゴリが追加されていること' do
      is_asserted_by { @driver.find_element(:xpath, "//input[@value='新カテゴリ']") }
    end
  end

  describe '収支情報を削除する' do
    before(:all) do
      @wait.until { (not @driver.find_element(:class, 'modal-backdrop')) rescue true }
      @driver.find_element(:xpath, '//td[@class="delete"]/button').click
      @wait.until { @driver.find_element(:class, 'bootbox-confirm').displayed? }
    end

    it 'ダイアログのタイトルが正しいこと' do
      xpath = '//div[contains(@class, "bootbox-confirm")]//div[@class="bootbox-body"]'
      is_asserted_by do
        @driver.find_element(:xpath, xpath).text == '本当に削除しますか？'
      end
    end
  end

  describe '削除を確定する' do
    before(:all) do
      xpath = '//div[@class="modal-footer"]/button[@class="btn btn-success"]'
      @driver.find_element(:xpath, xpath).click

      xpath = '//div[@class="bootbox modal fade bootbox-confirm in"]'
      @wait.until { @driver.find_element(:xpath, xpath) rescue true }
    end

    it_behaves_like '表示されている件数が正しいこと', per_page, 1, per_page
    it_behaves_like '収支情報の数が正しいこと', per_page
  end

  describe '2ページ目にアクセスする' do
    include_context '収支情報を入力する', default_inputs, 'income'
    include_context '登録ボタンを押す'
    before(:all) do
      @wait.until do
        @driver.find_element(:xpath, '//span[@class="next"]').click rescue false
      end
      @wait.until { URI.parse(@driver.current_url).query == 'page=2' }
    end

    it_behaves_like '表示されている件数が正しいこと',
                    per_page + 1, per_page + 1, per_page + 1
    it_behaves_like '収支情報の数が正しいこと', 1
  end

  describe '不正な金額を入力して検索する' do
    before(:all) do
      @driver.find_element(:xpath, '//a[@href="#search-form"]').click
      @driver.find_element(:name, 'price_upper').send_keys('invalid')
      @driver.find_element(:id, 'search-button').click
      @wait.until { @driver.find_element(:class, 'bootbox-alert').displayed? }
    end

    after(:all) do
      button = @wait.until { @driver.find_element(:xpath, '//div/button[text()="OK"]') }
      button.click
      @wait.until { not @driver.find_element(:class, 'bootbox-alert').displayed? }
      @driver.find_element(:name, 'price_upper').clear
    end

    it_behaves_like '正しくエラーダイアログが表示されていること',
                    message: '金額 が不正です'
  end

  describe '10000円以下の収支情報を検索する' do
    before(:all) do
      @wait.until do
        @driver.find_element(:xpath, '//a[@href="#search-form"]').click rescue false
      end
      @driver.find_element(:name, 'price_lower').send_keys('10000')
      @driver.find_element(:id, 'search-button').click
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
      @wait.until { not @driver.find_element(:class, 'bootbox-alert').displayed? }
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
        @driver.find_element(:xpath, '//a[@href="#search-form"]').click rescue false
      end
      @driver.find_element(:name, 'price_upper').send_keys('1000')
      @driver.find_element(:id, 'search-button').click
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
        @driver.find_element(:xpath, '//a[@href="#search-form"]').click rescue false
      end
      @driver.find_element(:name, 'price_upper').clear
      @driver.find_element(:name, 'price_lower').clear
      @driver.find_element(:name, 'category').send_keys('テスト,新カテゴリ')
      @driver.find_element(:id, 'search-button').click
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
        @driver.find_element(:xpath, '//a[@href="#search-form"]').click rescue false
      end
      @driver.find_element(:id, 'query_date_after').click
    end

    it 'カレンダーが表示されていること' do
      is_asserted_by { @driver.find_element(:class, 'bootstrap-datetimepicker-widget') }
    end
  end
end
