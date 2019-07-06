# coding: utf-8

require 'rails_helper'

describe 'ブラウザから辞書を登録する', type: :request do
  alert_xpath = '//div[contains(@class, "bootbox-alert")]'
  default_input = {
    phrase: Time.now.strftime('%F%T'),
    condition: 'include',
    categories: ['test'],
  }

  shared_context '辞書情報を入力する' do |input = default_input|
    before(:all) do
      @wait.until do
        @driver.find_element(:xpath, '//a[text()="辞書登録"]').click rescue false
      end

      phrase_input = @wait.until { @driver.find_element(:id, 'phrase') }
      phrase_input.clear
      phrase_input.send_keys(input[:phrase])

      select_xpath = '//select[@id="condition"]'
      @wait.until { @driver.find_element(:xpath, select_xpath) }
      option_xpath = "#{select_xpath}/option[@value='#{input[:condition]}']"
      @wait.until { @driver.find_element(:xpath, option_xpath).click }

      category_input = @wait.until { @driver.find_element(:id, 'dictionary_categories') }
      category_input.clear
      category_input.send_keys(input[:categories].join(','))
    end
  end

  shared_context '登録ボタンを押す' do
    before(:all) do
      @wait.until do
        @driver.find_element(:id, 'btn-create-dictionary') rescue false
      end.click
    end
  end

  shared_examples '登録に成功していること' do
    it 'タイトルが正しいこと' do
      xpath = "#{alert_xpath}//div[@class='bootbox-body']"
      @wait.until { @driver.find_element(:xpath, xpath).displayed? }
      is_asserted_by { @driver.find_element(:xpath, xpath).text == '登録が完了しました' }
    end

    it 'OKボタンがあること' do
      xpath = "#{alert_xpath}//div[@class='modal-footer']/button"
      is_asserted_by { @driver.find_element(:xpath, xpath).text == 'OK' }
    end
  end

  shared_examples '入力フォームが全て空であること' do
    %w[phrase dictionary_categories].each do |id|
      it_is_asserted_by { @driver.find_element(:id, id).text == '' }
    end
  end

  before(:all) do
    header = {'Authorization' => app_auth_header}
    res = http_client.get("#{base_url}/api/payments", {per_page: 100}, header)
    JSON.parse(res.body).each do |payment|
      http_client.delete("#{base_url}/api/payments/#{payment['id']}", nil, header)
    end
  end

  after(:all) do
    header = {'Authorization' => app_auth_header}
    res = http_client.get("#{base_url}/api/payments", {per_page: 100}, header)
    JSON.parse(res.body).each do |payment|
      http_client.delete("#{base_url}/api/payments/#{payment['id']}", nil, header)
    end
  end

  body = {
    payment_type: 'expense',
    date: '1000-01-01',
    content: 'システムテスト用データ',
    category: 'test',
    price: 100,
  }
  include_context 'POST /api/payments', body
  include_context 'Webdriverを起動する'
  include_context 'Cookieをセットする'

  before(:all) { @driver.get("#{base_url}/payments") }

  describe '辞書情報を登録する' do
    include_context '辞書情報を入力する'
    include_context '登録ボタンを押す'
    after(:all) do
      xpath = "#{alert_xpath}//div[@class='modal-footer']/button"
      @wait.until { @driver.find_element(:xpath, xpath).click rescue false }
    end

    it_behaves_like '登録に成功していること'
    it_behaves_like '入力フォームが全て空であること'
  end

  describe '新しいカテゴリで辞書情報を登録する' do
    input = default_input.merge(condition: 'equal', categories: ['new_test'])
    include_context '辞書情報を入力する', input
    include_context '登録ボタンを押す'
    after(:all) do
      xpath = "#{alert_xpath}//div[@class='modal-footer']/button"
      @wait.until { @driver.find_element(:xpath, xpath).click rescue false }
    end

    it_behaves_like '登録に成功していること'
    it_behaves_like '入力フォームが全て空であること'
  end

  describe 'カテゴリ一覧を確認する' do
    before(:all) do
      @driver.get("#{base_url}/payments")
      @wait.until do
        @driver.find_element(:xpath, '//a[text()="辞書登録"]').click rescue false
      end
      xpath = '//form[@id="new_dictionary"]//span[@class="category-list"]/button'
      @wait.until { @driver.find_element(:xpath, xpath).click rescue false }
      @wait.until { @driver.find_element(:class, 'bootbox-prompt').displayed? }
    end

    after(:all) do
      xpath = '//div[contains(@class, "bootbox-prompt")]//button[text()="Cancel"]'
      cancel_button = @wait.until { @driver.find_element(:xpath, xpath) }
      cancel_button.click
      @wait.until { @driver.find_element(:xpath, xpath) rescue true }
    end

    it '新カテゴリが追加されていること' do
      binding.pry
      is_asserted_by do
        @wait.until { @driver.find_element(:xpath, "//input[@value='new_test']") }
      end
    end
  end
end
