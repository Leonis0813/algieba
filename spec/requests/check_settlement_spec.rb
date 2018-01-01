# coding: utf-8
require 'rails_helper'

describe '統計情報を確認する', :type => :request do
  before(:all) do
    @driver = Selenium::WebDriver.for :firefox
    @wait = Selenium::WebDriver::Wait.new(:timeout => 60)
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
  end
end
