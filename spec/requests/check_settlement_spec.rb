# coding: utf-8
require 'rails_helper'

describe '統計情報を確認する', type: :request do
  before(:all) do
    payment = {
      date: '2018-01-01',
      payment_type: 'income',
      content: 'regist from view',
      category: 'テスト',
      price: 100,
    }
    body = {payments: payment}.to_json
    header = {'Authorization' => app_auth_header}.merge(content_type_json)
    res = http_client.post("#{base_url}/api/payments", body, header)
    @payment_id = JSON.parse(res.body)['id']
  end

  after(:all) do
    header = {'Authorization' => app_auth_header}
    http_client.delete("#{base_url}/api/payments/#{@payment_id}", nil, header)
  end

  include_context 'Webdriverを起動する'
  include_context 'Cookieをセットする'

  describe '統計情報確認画面を開く' do
    before(:all) do
      @driver.get("#{base_url}/payments")
      @driver.find_element(:xpath, '//li/a[text()="統計画面"]').click
    end

    it '統計情報確認画面が表示されていること' do
      is_asserted_by { @driver.current_url == "#{base_url}/statistics" }
    end

    it '月次の棒グラフが表示されていること' do
      xpath = '//*[@id="monthly"][@width="1200"][@height="300"]'
      is_asserted_by do
        @wait.until { @driver.find_element(:xpath, xpath) }
      end
    end

    it '日次の棒グラフが表示されていないこと' do
      expect do
        @driver.find_element(:xpath, '//*[@id="daily"][@width="1200"][@height="300"]')
      end.to raise_error Selenium::WebDriver::Error::NoSuchElementError
    end
  end

  describe 'x軸のラベルをクリックする' do
    before(:all) { @driver.execute_script('settlement.drawDaily("2018-01")') }

    it '日次の棒グラフが表示されていること' do
      xpath = '//*[@id="daily"][@width="1200"][@height="300"]'
      is_asserted_by do
        @wait.until { @driver.find_element(:xpath, xpath) }
      end
    end
  end
end
