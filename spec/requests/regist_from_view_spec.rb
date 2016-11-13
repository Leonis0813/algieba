# coding: utf-8
require 'rails_helper'

describe 'ブラウザから操作する', :type => :request do
  default_inputs = {:date => '1000-01-01', :content => 'regist from view', :category => 'テスト', :price => 100}
  color = {'収入' => 'success', '支出' => 'danger'}

  shared_context '家計簿を登録する' do |inputs, account_type|
    before(:all) do
      inputs.each do |key, value|
        element = @driver.find_element(:id, "accounts_#{key}")
        element.clear
        element.send_keys(value.to_s)
      end
      @driver.find_element(:id, "accounts_account_type_#{account_type}").click
      @driver.find_element(:xpath, '//form/span/input[@value="登録"]').click
      sleep 1
    end
  end

  shared_examples '家計簿の数が正しいこと' do |expected_size|
    it { expect(@driver.find_elements(:xpath, '//table/tbody/tr').size).to eq expected_size }
  end

  shared_examples 'ページングボタンが表示されていないこと' do
    it do
      expect{ @driver.find_element(:xpath, '//nav[@class="pagination"]') }.to raise_error Selenium::WebDriver::Error::NoSuchElementError
    end
  end

  shared_examples 'ページングボタンが表示されていること' do
    it { expect(@driver.find_element(:xpath, '//nav[@class="pagination"]')).to be }
  end

  shared_examples '背景色が正しいこと' do
    it do
      @driver.find_elements(:xpath, '//table/tbody/tr').each do |element|
        type = element.find_element(:xpath, './td').text
        expect(element.find_element(:xpath, "../tr[@class='#{color[type]}']")).to be
      end
    end
  end

  before(:all) do
    header = {'Authorization' => app_auth_header}
    res = http_client.get("#{base_url}/accounts", nil, header)
    size = JSON.parse(res.body).size
    account = default_inputs.merge(:account_type => 'income')

    header = {'Authorization' => app_auth_header}.merge(content_type_json)
    (Kaminari.config.default_per_page - 1 - size).times do
      http_client.post("#{base_url}/accounts", {:accounts => account}.to_json, header)
    end
  end

  after(:all) do
    header = {'Authorization' => app_auth_header}
    res = http_client.get("#{base_url}/accounts", {:content_equal => 'regist from view'}, header)
    accounts = JSON.parse(res.body)
    accounts.each {|account| http_client.delete("#{base_url}/accounts/#{account['id']}", nil, header) }
  end

  describe '管理画面を開く' do
    before(:all) do
      @driver = Selenium::WebDriver.for :firefox
      @driver.get(base_url)
    end

    it 'ログイン画面にリダイレクトされていること' do
      expect(@driver.current_url).to eq "#{base_url}/login"
    end

    describe 'ログインする' do
      before(:all) do
        @driver.find_element(:id, 'user_id').send_keys('test_user_id')
        @driver.find_element(:id, 'password').send_keys('test_user_pass')
        @driver.find_element(:id => 'login').click
      end

      it '管理画面が開いていること' do
        expect(@driver.current_url).to eq "#{base_url}/"
      end

      %w[ date content category price ].each do |column|
        it "入力欄(id=accounts_#{column})が全て空白であること" do
          expect(@driver.find_element(:id, "accounts_#{column}").text).to eq ''
        end
      end

      it_behaves_like '家計簿の数が正しいこと', Kaminari.config.default_per_page - 1
      it_behaves_like 'ページングボタンが表示されていないこと'

      describe '家計簿を登録する' do
        include_context '家計簿を登録する', default_inputs.merge(:date => 'invalid_date'), 'income'
        it_behaves_like '家計簿の数が正しいこと', Kaminari.config.default_per_page - 1
        it_behaves_like 'ページングボタンが表示されていないこと'

        describe '家計簿を登録する' do
          include_context '家計簿を登録する', default_inputs, 'expense'
          it_behaves_like '家計簿の数が正しいこと', Kaminari.config.default_per_page
          it_behaves_like 'ページングボタンが表示されていないこと'
          it_behaves_like '背景色が正しいこと'

          describe '家計簿を登録する' do
            include_context '家計簿を登録する', default_inputs, 'income'
            it_behaves_like '家計簿の数が正しいこと', Kaminari.config.default_per_page
            it_behaves_like 'ページングボタンが表示されていること'
            it_behaves_like '背景色が正しいこと'
          end
        end
      end
    end
  end
end
