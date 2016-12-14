# coding: utf-8
require 'rails_helper'

describe 'ブラウザから操作する', :type => :request do
  per_page =  Kaminari.config.default_per_page
  default_inputs = {:date => '1000-01-01', :content => 'regist from view', :category => 'テスト', :price => 100}
  color = {'収入' => 'success', '支出' => 'danger'}

  shared_context '家計簿を登録する' do |inputs, payment_type|
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
    %w[ date content category price ].each do |column|
      it { expect(@driver.find_element(:id, "payments_#{column}").text).to eq '' }
    end
  end

  shared_examples '表示されている件数が正しいこと' do |total, from, to|
    it { expect(@driver.find_element(:id, 'total_count').text).to eq "#{total}件中#{from}〜#{to}件を表示" }
  end

  shared_examples 'ページングボタンが表示されていないこと' do
    it do
      expect{ @driver.find_element(:xpath, '//nav[@class="pagination"]') }.to raise_error Selenium::WebDriver::Error::NoSuchElementError
    end
  end

  shared_examples 'ページングボタンが表示されていること' do
    it { expect(@driver.find_element(:xpath, '//nav[@class="pagination"]')).to be }
  end

  shared_examples '家計簿の数が正しいこと' do |expected_size|
    it { expect(@driver.find_elements(:xpath, '//table/tbody/tr').size).to eq expected_size }
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
    res = http_client.get("#{base_url}/payments", nil, header)
    size = JSON.parse(res.body).size
    payment = default_inputs.merge(:payment_type => 'income')

    header = {'Authorization' => app_auth_header}.merge(content_type_json)
    (per_page - 1 - size).times do
      http_client.post("#{base_url}/payments", {:payments => payment}.to_json, header)
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
      expect(@driver.current_url).to eq "#{base_url}/login"
    end

    describe 'ログインする' do
      before(:all) do
        @driver.find_element(:id, 'user_id').send_keys('test_user_id')
        @driver.find_element(:id, 'password').send_keys('test_user_pass')
        @driver.find_element(:id, 'login').click
      end

      it '管理画面が開いていること' do
        expect(@driver.current_url).to eq "#{base_url}/"
      end

      it_behaves_like '入力フォームが全て空であること'
      it_behaves_like '表示されている件数が正しいこと', per_page - 1, 1, per_page - 1
      it_behaves_like 'ページングボタンが表示されていないこと'
      it_behaves_like '家計簿の数が正しいこと', per_page - 1

      describe '家計簿を登録する' do
        include_context '家計簿を登録する', default_inputs.merge(:date => 'invalid_date'), 'income'

        it 'エラーダイアログが表示されていること' do
          expect(@driver.find_element(:xpath, '//div[@class="bootbox modal fade bootbox-alert in"]')).to be
        end

        it 'ダイアログのタイトルが正しいこと' do
          expect(@driver.find_element(:xpath, '//h4[@class="modal-title"]').text).to eq 'エラー'
        end

        it 'エラーメッセージが正しいこと' do
          expect(@driver.find_element(:xpath, '//div[@class="text-center alert alert-danger"]').text).to eq '日付 が不正です'
        end

        it_behaves_like '表示されている件数が正しいこと', per_page - 1, 1, per_page - 1
        it_behaves_like 'ページングボタンが表示されていないこと'
        it_behaves_like '家計簿の数が正しいこと', per_page - 1

        describe '入力をリセットする' do
          before(:all) do
            @driver.find_element(:xpath, '//div[@class="modal-footer"]/button').click
            sleep 1
          end
          include_context 'リセットボタンを押す'
          it_behaves_like '入力フォームが全て空であること'

          describe '家計簿を登録する' do
            include_context '家計簿を登録する', default_inputs, 'expense'
            it_behaves_like '表示されている件数が正しいこと', per_page, 1, per_page
            it_behaves_like 'ページングボタンが表示されていないこと'
            it_behaves_like '家計簿の数が正しいこと', per_page
            it_behaves_like '背景色が正しいこと'

            describe '家計簿を登録する' do
              include_context 'リセットボタンを押す'
              include_context '家計簿を登録する', default_inputs, 'income'
              it_behaves_like '表示されている件数が正しいこと', per_page + 1, 1, per_page
              it_behaves_like 'ページングボタンが表示されていること'
              it_behaves_like '家計簿の数が正しいこと', per_page
              it_behaves_like '背景色が正しいこと'

              describe '2ページ目にアクセスする' do
                before(:all) do
                  @driver.find_element(:xpath, '//span[@class="next"]').click
                  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
                  wait.until { URI.parse(@driver.current_url).query == 'page=2' }
                end
                it_behaves_like '表示されている件数が正しいこと', per_page + 1, per_page + 1, per_page + 1
                it_behaves_like 'ページングボタンが表示されていること'
                it_behaves_like '家計簿の数が正しいこと', 1
                it_behaves_like '背景色が正しいこと'
              end
            end
          end
        end
      end
    end
  end
end
