# coding: utf-8

require 'rails_helper'

describe 'ブラウザから収支を登録する', type: :request do
  per_page = Kaminari.config.default_per_page
  default_inputs = {
    date: '1000-01-01',
    content: 'regist from view',
    categories: ['テスト'],
    price: 100,
  }

  shared_context '収支情報を入力する' do |inputs, payment_type|
    before(:all) do
      @wait.until { @driver.find_element(:id, 'payment_date').displayed? }
      inputs.except(:categories).each do |key, value|
        element = @driver.find_element(:id, "payment_#{key}")
        element.clear
        element.send_keys(value.to_s)
      end
      xpath = '//form[@id="new_payment"]//span[@class="category-list"]/button'
      @driver.find_element(:xpath, xpath).click

      inputs[:categories].each do |category|
        xpath = "//div[@class='modal-dialog']//input[@value='#{category}']"
        @wait.until do
          @driver.find_element(:xpath, xpath).selected? ||
            (@driver.find_element(:xpath, xpath).click rescue false)
        end
      end

      xpath = '//button[@data-bb-handler="confirm"]'
      @wait.until { @driver.find_element(:xpath, xpath).click rescue false }

      xpath = '//h4[text()="カテゴリを選択してください"]'
      @wait.until { (not @driver.find_element(:xpath, xpath).displayed?) rescue true }

      id = "payment_payment_type_#{payment_type}"
      @wait.until { @driver.find_element(:id, id).click rescue false }
    end
  end

  shared_context '登録ボタンを押す' do
    before(:all) do
      xpath = '//form[@id="new_payment"]/input[@value="登録"]'
      @wait.until { @driver.find_element(:xpath, xpath).click rescue false }
    end
  end

  shared_examples '入力フォームが全て空であること' do
    %w[date content categories price].each do |column|
      it_is_asserted_by { @driver.find_element(:id, "payment_#{column}").text == '' }
    end
  end

  shared_examples '辞書を登録するダイアログが表示されていること' do |category|
    it do
      phrase = @wait.until { @driver.find_element(:id, 'dialog-phrase') }
      is_asserted_by { phrase.present? }
      is_asserted_by { phrase.text == 'register from view' }

      xpath = '//select[@id="dialog-condition"]/option[@selected][@value="と一致する"]'
      selected_condition = @wait.until { @driver.find_element(:xpath, xpath) }
      is_asserted_by { selected_condition.present? }

      categories = @wait.until { @driver.find_element(:id, 'dialog-categories') }
      is_asserted_by { categories.present? }
      is_asserted_by { categories.text == category }
    end
  end

  before(:all) do
    payment = default_inputs.merge(payment_type: 'income', categories: ['テスト'])

    header = app_auth_header.merge(content_type_json)
    (per_page - 1).times do
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
      @wait.until { @driver.find_element(:id, 'payment_price').enabled? rescue false }
      element = @driver.find_element(:id, 'payment_price')
      element.clear
      element.send_keys('100')
    end
    include_context '登録ボタンを押す'

    it_behaves_like '辞書を登録するダイアログが表示されていること', category: 'テスト'

    describe '辞書登録をキャンセルする' do
      before(:all) do
        xpath = '//button[@data-bb-handler="cancel"]'
        @wait.until { @driver.find_element(:xpath, xpath).click rescue false }
      end

      it_behaves_like '表示されている件数が正しいこと', per_page, 1, per_page
      it_behaves_like '収支情報の数が正しいこと', per_page
    end
  end

  describe 'カレンダーを表示する' do
    before(:all) do
      @wait.until { @driver.find_element(:id, 'payment_date').displayed? }
      @driver.find_element(:id, 'payment_date').click
    end

    it 'カレンダーが表示されていること' do
      is_asserted_by { @driver.find_element(:class, 'bootstrap-datetimepicker-widget') }
    end
  end

  describe '新しいカテゴリで収支情報を登録する' do
    include_context '収支情報を入力する', default_inputs.except, 'income'
    before(:all) do
      element = @driver.find_element(:id, 'payment_categories')
      element.clear
      element.send_keys('新カテゴリ')
    end
    include_context '登録ボタンを押す'

    it_behaves_like '辞書を登録するダイアログが表示されていること', category: '新カテゴリ'
    describe '辞書を登録する' do
      before(:all) do
        xpath = '//button[@data-bb-handler="ok"]'
        @wait.until { @driver.find_element(:xpath, xpath).click rescue false }
      end

      it_behaves_like '表示されている件数が正しいこと', per_page + 1, 1, per_page
      it_behaves_like '収支情報の数が正しいこと', per_page
    end
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

  describe '内容を入力する' do
    before(:all) do
      @wait.until { @driver.find_element(:id, 'payment_date').displayed? }
      element = @wait.until { @driver.find_element(:id, 'payment_content') }
      element.send_keys(default_inputs[:content])
      element.send_keys(:tab)
    end

    it 'カテゴリが入力されていること' do
      category = @wait.until { @driver.find_element(:id, 'payment_categories') }
      is_asserted_by { category.text == '新カテゴリ' }
    end

    describe '収支情報を登録する' do
      before(:all) do
        @wait.until { @driver.find_element(:id, 'payment_date').displayed? }
        @wait.until do
          @driver.find_element(:id, 'payment_date').send_keys(default_inputs[:date])
        end
        @wait.until do
          @driver.find_element(:id, 'payment_payment_type_income').click rescue false
        end
      end
      include_context '登録ボタンを押す'

      it_behaves_like '表示されている件数が正しいこと', per_page + 1, 1, per_page
      it_behaves_like '収支情報の数が正しいこと', per_page
    end
  end

  describe '2ページ目にアクセスする' do
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
end
