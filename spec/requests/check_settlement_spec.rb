# coding: utf-8
require 'rails_helper'

describe '統計情報を確認する', :type => :request do
  before(:all) do
    payment = {:date => '2018-01-01', :payment_type => 'income', :content => 'regist from view', :category => 'テスト', :price => 100}
    header = {'Authorization' => app_auth_header}.merge(content_type_json)
    res = http_client.post("#{base_url}/api/payments", {:payments => payment}.to_json, header)
    @payment_id = JSON.parse(res.body)['id']

    @driver = Selenium::WebDriver.for :firefox
    @wait = Selenium::WebDriver::Wait.new(:timeout => 60)
  end

  after(:all) do
    header = {'Authorization' => app_auth_header}
    http_client.delete("#{base_url}/api/payments/#{@payment_id}", nil, header)
  end

  describe '統計情報確認画面を開く' do
    before(:all) { @driver.get("#{base_url}/statistics") }

    it 'ログイン画面にリダイレクトされていること' do
      is_asserted_by { @driver.current_url == "#{base_url}/login" }
    end
  end

  describe 'ログインする' do
    before(:all) do
      @driver.find_element(:id, 'user_id').send_keys('test_user_id')
      @driver.find_element(:id, 'password').send_keys('test_user_pass')
      @driver.find_element(:id, 'login').click
    end

    it '管理画面が表示されていること' do
      is_asserted_by { @driver.current_url == "#{base_url}/payments" }
    end
  end

  describe '統計情報確認画面を開く' do
    before(:all) { @driver.find_element(:id, 'btn-stats').click }

    it '統計情報確認画面が表示されていること' do
      is_asserted_by { @driver.current_url == "#{base_url}/statistics" }
    end

    it '月次の棒グラフが表示されていること' do
      is_asserted_by { @driver.find_element(:id, 'settlement-monthly') }
    end

    it '日次の棒グラフが表示されていないこと' do
      expect{ @driver.find_element(:id, 'settlement-daily') }.to raise_error Selenium::WebDriver::Error::NoSuchElementError
    end
  end

  describe 'x軸のラベルをクリックする' do
    before(:all) { @driver.execute_script('settlement.drawDaily("2018-01")') }

    it '日次の棒グラフが表示されていること' do
      is_asserted_by { @driver.find_element(:id, 'settlement-daily') }
    end
  end
end
