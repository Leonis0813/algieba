# coding: utf-8
require 'rails_helper'

describe 'ブラウザから操作する', :type => :request, :js => true do
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

  before(:all) do
    res = http_client.get("#{base_url}/accounts")
    size = JSON.parse(res.body).size
    account = default_inputs.merge(:account_type => 'income')
    (Kaminari.config.default_per_page - 1 - size).times do
      http_client.post("#{base_url}/accounts", {:accounts => account}.to_json, content_type_json)
    end
  end

  after(:all) do
    res = http_client.get("#{base_url}/accounts", :content_equal => 'regist from view')
    accounts = JSON.parse(res.body)
    accounts.each {|account| http_client.delete("#{base_url}/accounts/#{account['id']}") }
  end

  describe '管理画面を開く' do
    before(:all) do
      @driver = Selenium::WebDriver.for :firefox
      @driver.get('http://160.16.66.112:3000')
    end

    it 'ログイン画面にリダイレクトされていること' do
      expect(URI.parse(@driver.current_url).path).to eq '/login'
    end

    describe 'ログインする' do
      before(:all) do
        @driver.find_element(:id, 'user_id').send_keys('test_user_id')
        @driver.find_element(:id, 'password').send_keys('test_user_pass')
        @driver.find_element(:id => 'login').click
      end

      it '管理画面が開いていること' do
        expect(URI.parse(@driver.current_url).path).to eq '/'
      end

      %w[ date content category price ].each do |column|
        it "入力欄(id=accounts_#{column})が全て空白であること" do
          expect(@driver.find_element(:id, "accounts_#{column}").text).to eq ''
        end
      end

      it '入力欄の下に家計簿が表示されていること' do
        expect(@driver.find_elements(:xpath, '//table/tbody/tr').size).to eq (Kaminari.config.default_per_page - 1)
      end

      it 'ページングボタンが表示されていないこと' do
        expect{ @driver.find_element(:xpath, '//nav[@class="pagination"]') }.to raise_error Selenium::WebDriver::Error::NoSuchElementError
      end

      describe '家計簿を登録する' do
        include_context '家計簿を登録する', default_inputs.merge(:date => 'invalid_date'), 'income'

        it '家計簿の数が変わっていないこと' do
          expect(@driver.find_elements(:xpath, '//table/tbody/tr').size).to eq (Kaminari.config.default_per_page - 1)
        end

        it 'ページングボタンが表示されていないこと' do
          expect{ @driver.find_element(:xpath, '//nav[@class="pagination"]') }.to raise_error Selenium::WebDriver::Error::NoSuchElementError
        end

        describe '家計簿を登録する' do
          include_context '家計簿を登録する', default_inputs, 'expense'

          it '家計簿の数が1つ増えていること' do
            expect(@driver.find_elements(:xpath, '//table/tbody/tr').size).to eq Kaminari.config.default_per_page
          end

          it 'ページングボタンが表示されていること' do
            expect(@driver.find_element(:xpath, '//nav[@class="pagination"]')).to be
          end

          it '背景色が正しいこと' do
            @driver.find_elements(:xpath, '//table/tbody/tr').each do |element|
              type = element.find_element(:xpath, './td').text
              expect(element.find_element(:xpath, "../tr[@class='#{color[type]}']")).to be
            end
          end

          describe '家計簿を登録する' do
            include_context '家計簿を登録する', default_inputs, 'income'

            it '表示されている家計簿の数が変わっていないこと' do
              expect(@driver.find_elements(:xpath, '//table/tbody/tr').size).to eq Kaminari.config.default_per_page
            end

            it 'ページングボタンが表示されていること' do
              expect(@driver.find_element(:xpath, '//nav[@class="pagination"]')).to be
            end

            it '背景色が正しいこと' do
              @driver.find_elements(:xpath, '//table/tbody/tr').each do |element|
                type = element.find_element(:xpath, './td').text
                expect(element.find_element(:xpath, "../tr[@class='#{color[type]}']")).to be
              end
            end
          end
        end
      end
    end
  end
end
