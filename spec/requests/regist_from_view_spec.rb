# coding: utf-8
require 'rails_helper'

describe 'ブラウザから操作する', :type => :request do
  per_page =  Kaminari.config.default_per_page
  default_inputs = {:date => '1000-01-01', :content => 'regist from view', :categories => 'テスト', :price => 100}
  color = {'収入' => 'success', '支出' => 'danger'}

  shared_context '収支情報を登録する' do |inputs, payment_type|
    before(:all) do
      inputs.each {|key, value| @driver.find_element(:id, "payments_#{key}").send_keys(value.to_s) }
      @driver.find_element(:id, "payments_payment_type_#{payment_type}").click
      @driver.find_element(:xpath, '//form/span/input[@value="登録"]').click
      sleep 1
    end
  end

  shared_context 'リセットボタンを押す' do
    before(:all) { @driver.find_element(:xpath, '//form/span/input[@value="リセット"]').click }
  end

  shared_examples '入力フォームが全て空であること' do
    %w[ date content categories price ].each do |column|
      it_is_asserted_by { @driver.find_element(:id, "payments_#{column}").text == '' }
    end
  end

  shared_examples '表示されている件数が正しいこと' do |total, from, to|
    it_is_asserted_by { @driver.find_element(:xpath, '//div[@class="row row-center"]/div').text == "#{total}件中#{from}〜#{to}件を表示" }
  end

  shared_examples 'ページングボタンが表示されていないこと' do
    it do
      expect{ @driver.find_element(:xpath, '//nav[@class="pagination"]') }.to raise_error Selenium::WebDriver::Error::NoSuchElementError
    end
  end

  shared_examples 'ページングボタンが表示されていること' do
    it_is_asserted_by { @driver.find_element(:xpath, '//nav[@class="pagination"]') }
  end

  shared_examples '収支情報の数が正しいこと' do |expected_size|
    it_is_asserted_by { @driver.find_elements(:xpath, '//table/tbody/tr').size == expected_size }
  end

  shared_examples '背景色が正しいこと' do
    it do
      @driver.find_elements(:xpath, '//table/tbody/tr').each do |element|
        type = element.find_element(:xpath, './td').text
        is_asserted_by { element.find_element(:xpath, "./td[@class='#{color[type]}']") }
      end
    end
  end

  before(:all) do
    header = {'Authorization' => app_auth_header}
    res = http_client.get("#{base_url}/payments", nil, header)
    size = JSON.parse(res.body).size
    payment = default_inputs.merge(:payment_type => 'income')

    header = {'Authorization' => app_auth_header}.merge(content_type_json)
    (per_page - 1 - size).times do
      http_client.post("#{base_url}/payments", {:payments => payment.merge(:category => 'テスト')}.to_json, header)
    end
  end

  after(:all) do
    header = {'Authorization' => app_auth_header}
    res = http_client.get("#{base_url}/payments", {:content_equal => 'regist from view'}, header)
    payments = JSON.parse(res.body)
    payments.each {|payment| http_client.delete("#{base_url}/payments/#{payment['id']}", nil, header) }
  end

  describe '管理画面を開く' do
    before(:all) do
      @driver = Selenium::WebDriver.for :firefox
      @driver.get(base_url)
    end

    it 'ログイン画面にリダイレクトされていること' do
      is_asserted_by { @driver.current_url == "#{base_url}/login" }
    end

    describe 'ログインする' do
      before(:all) do
        @driver.find_element(:id, 'user_id').send_keys('test_user_id')
        @driver.find_element(:id, 'password').send_keys('test_user_pass')
        @driver.find_element(:id, 'login').click
      end

      it '管理画面が開いていること' do
        is_asserted_by { @driver.current_url == "#{base_url}/" }
      end

      it_behaves_like '入力フォームが全て空であること'
      it_behaves_like '表示されている件数が正しいこと', per_page - 1, 1, per_page - 1
      it_behaves_like 'ページングボタンが表示されていないこと'
      it_behaves_like '収支情報の数が正しいこと', per_page - 1

      describe '収支情報を登録する' do
        include_context '収支情報を登録する', default_inputs.merge(:date => 'invalid_date'), 'income'

        it 'エラーダイアログが表示されていること' do
          is_asserted_by { @driver.find_element(:xpath, '//div[@class="bootbox modal fade bootbox-alert in"]') }
        end

        it 'ダイアログのタイトルが正しいこと' do
          is_asserted_by { @driver.find_element(:xpath, '//h4[@class="modal-title"]').text == 'エラー' }
        end

        it 'エラーメッセージが正しいこと' do
          is_asserted_by { @driver.find_element(:xpath, '//div[@class="text-center alert alert-danger"]').text == '日付 が不正です' }
        end

        it_behaves_like '表示されている件数が正しいこと', per_page - 1, 1, per_page - 1
        it_behaves_like 'ページングボタンが表示されていないこと'
        it_behaves_like '収支情報の数が正しいこと', per_page - 1

        describe '入力をリセットする' do
          before(:all) do
            @driver.find_element(:xpath, '//div[@class="modal-footer"]/button').click
            sleep 1
          end
          include_context 'リセットボタンを押す'
          it_behaves_like '入力フォームが全て空であること'

          describe '収支情報を登録する' do
            include_context '収支情報を登録する', default_inputs, 'expense'
            it_behaves_like '表示されている件数が正しいこと', per_page, 1, per_page
            it_behaves_like 'ページングボタンが表示されていないこと'
            it_behaves_like '収支情報の数が正しいこと', per_page
            it_behaves_like '背景色が正しいこと'

            describe '収支情報を登録する' do
              include_context 'リセットボタンを押す'
              include_context '収支情報を登録する', default_inputs, 'income'
              it_behaves_like '表示されている件数が正しいこと', per_page + 1, 1, per_page
              it_behaves_like 'ページングボタンが表示されていること'
              it_behaves_like '収支情報の数が正しいこと', per_page
              it_behaves_like '背景色が正しいこと'

              describe '収支情報を削除する' do
                before(:all) do
                  @driver.find_element(:xpath, '//td[@class="delete"]/button').click
                  sleep 1
                end
                it_behaves_like '表示されている件数が正しいこと', per_page, 1, per_page
                it_behaves_like 'ページングボタンが表示されていないこと'
                it_behaves_like '収支情報の数が正しいこと', per_page
                it_behaves_like '背景色が正しいこと'

                describe '2ページ目にアクセスする' do
                  include_context 'リセットボタンを押す'
                  include_context '収支情報を登録する', default_inputs, 'income'
                  before(:all) do
                    @driver.find_element(:xpath, '//span[@class="next"]').click
                    wait = Selenium::WebDriver::Wait.new(:timeout => 10)
                    wait.until { URI.parse(@driver.current_url).query == 'page=2' }
                  end

                  it_behaves_like '表示されている件数が正しいこと', per_page + 1, per_page + 1, per_page + 1
                  it_behaves_like 'ページングボタンが表示されていること'
                  it_behaves_like '収支情報の数が正しいこと', 1
                  it_behaves_like '背景色が正しいこと'
                end
              end
            end
          end
        end
      end
    end
  end
end
