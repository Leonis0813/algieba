# coding: utf-8
require 'rails_helper'

describe 'ブラウザから操作する', :type => :request do
  per_page =  Kaminari.config.default_per_page
  default_inputs = {:date => '1000-01-01', :content => 'regist from view', :categories => 'テスト', :price => 100}
  color = {'収入' => 'success', '支出' => 'danger'}

  shared_context '収支情報を入力する' do |inputs, payment_type|
    before(:all) do
      inputs.except(:categories).each {|key, value| @driver.find_element(:id, "payments_#{key}").send_keys(value.to_s) }
      @driver.find_element(:xpath, '//span[@id="category-list"]/button').click
      @wait.until { @driver.find_element(:xpath, "//input[@value='#{inputs[:categories]}']").click rescue false }
      @driver.find_element(:xpath, '//button[@data-bb-handler="confirm"]').click
      @wait.until { (not @driver.find_element(:xpath, '//div[@class="modal-body"]')) rescue true }
      @driver.find_element(:id, "payments_payment_type_#{payment_type}").click
    end
  end

  shared_context '登録ボタンを押す' do
    before(:all) { @driver.find_element(:xpath, '//form/span/input[@value="登録"]').click }
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

  shared_examples 'URLにクエリがセットされていること' do |expected_query = {}|
    it_is_asserted_by { URI.parse(@driver.current_url).query.symbolize_keys == expected_query }
  end

  shared_examples 'フォームに値がセットされていること' do |attribute|
    it_is_asserted_by { @driver.find_element(:xpath, "//input[@name='#{attribute[:name]}'][@value='#{attribute[:value]}']") }
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

    @driver = Selenium::WebDriver.for :firefox
    @wait = Selenium::WebDriver::Wait.new(:timeout => 60)
  end

  after(:all) do
    header = {'Authorization' => app_auth_header}
    res = http_client.get("#{base_url}/payments", {:content_equal => 'regist from view'}, header)
    payments = JSON.parse(res.body)
    payments.each {|payment| http_client.delete("#{base_url}/payments/#{payment['id']}", nil, header) }
  end

  describe '管理画面を開く' do
    before(:all) { @driver.get("#{base_url}/payments.html") }

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

    it '管理画面が開いていること' do
      is_asserted_by { @driver.current_url == "#{base_url}/payments.html" }
    end

    it_behaves_like '入力フォームが全て空であること'
    it_behaves_like '表示されている件数が正しいこと', per_page - 1, 1, per_page - 1
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like '収支情報の数が正しいこと', per_page - 1
  end

  describe '不正な収支情報を登録する' do
    include_context '収支情報を入力する', default_inputs.merge(:price => 'invalid_price'), 'income'
    include_context '登録ボタンを押す'
    before(:all) { @wait.until { not @driver.find_element(:class, 'modal-title').text.empty? } }

    it 'ダイアログのタイトルが正しいこと' do
      is_asserted_by { @driver.find_element(:xpath, '//h4[@class="modal-title"]').text == 'エラー' }
    end

    it 'エラーメッセージが正しいこと' do
      is_asserted_by { @driver.find_element(:xpath, '//div[@class="text-center alert alert-danger"]').text == '金額 が不正です' }
    end

    it_behaves_like '表示されている件数が正しいこと', per_page - 1, 1, per_page - 1
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like '収支情報の数が正しいこと', per_page - 1
  end

  describe '入力をリセットする' do
    before(:all) do
      @driver.find_element(:xpath, '//div[@class="modal-footer"]/button').click
      @wait.until { (not @driver.find_element(:xpath, '//div[@role="dialog"]')) rescue true }
    end
    include_context 'リセットボタンを押す'
    it_behaves_like '入力フォームが全て空であること'
  end

  describe '収支情報を登録する' do
    include_context '収支情報を入力する', default_inputs.merge(:date => Date.today.strftime('%Y-%m-%d')), 'expense'
    include_context '登録ボタンを押す'
    before(:all) { @wait.until { @driver.find_element(:xpath, '//div[@class="row row-center"]/div').text =~ /^#{per_page}/ } }

    it_behaves_like '表示されている件数が正しいこと', per_page, 1, per_page
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like '収支情報の数が正しいこと', per_page
    it_behaves_like '背景色が正しいこと'
  end

  describe 'カレンダーを表示する' do
    before(:all) { @driver.find_element(:id, 'payments_date').click }

    it 'カレンダーが表示されていること' do
      is_asserted_by { @driver.find_element(:class, 'bootstrap-datetimepicker-widget') }
    end
  end

  describe '日付を選択する' do
    before(:all) { @driver.find_element(:class, 'today').click }

    it 'カレンダーが表示されていないこと' do
      expect{ @driver.find_element(:class, 'bootstrap-datetimepicker-widget') }.to raise_error Selenium::WebDriver::Error::NoSuchElementError
    end
  end

  describe '収支情報を登録する' do
    include_context 'リセットボタンを押す'
    include_context '収支情報を入力する', default_inputs, 'income'
    before(:all) do
      element = @driver.find_element(:id, 'payments_categories')
      element.clear
      element.send_keys('新カテゴリ')
    end
    include_context '登録ボタンを押す'
    before(:all) { @wait.until { @driver.find_element(:xpath, '//div[@class="row row-center"]/div').text =~ /^#{per_page + 1}/ } }

    it_behaves_like '表示されている件数が正しいこと', per_page + 1, 1, per_page
    it_behaves_like 'ページングボタンが表示されていること'
    it_behaves_like '収支情報の数が正しいこと', per_page
    it_behaves_like '背景色が正しいこと'
  end

  describe 'カテゴリ一覧を確認する' do
    before(:all) { @driver.find_element(:xpath, '//span[@id="category-list"]/button').click }

    after(:all) do
      sleep 1
      @driver.find_element(:xpath, '//button[@data-bb-handler="cancel"]').click
      @wait.until { (not @driver.find_element(:xpath, '//div[@class="modal-body"]')) rescue true }
    end

    it '新カテゴリが追加されていること' do
      is_asserted_by { @driver.find_element(:xpath, "//input[@value='新カテゴリ']") }
    end
  end

  describe '収支情報を削除する' do
    before(:all) do
      @driver.find_element(:xpath, '//td[@class="delete"]/button').click
      sleep 1
    end

    it '確認ダイアログが表示されていること' do
      is_asserted_by { @driver.find_element(:xpath, '//div[@class="bootbox modal fade bootbox-confirm in"]') }
    end

    it 'ダイアログのタイトルが正しいこと' do
      is_asserted_by { @driver.find_element(:xpath, '//div[@class="modal-body"]/div[@class="bootbox-body"]').text == '本当に削除しますか？' }
    end
  end

  describe '削除を確定する' do
    before(:all) do
      @driver.find_element(:xpath, '//div[@class="modal-footer"]/button[@class="btn btn-success"]').click
      @wait.until { (not @driver.find_element(:xpath, '//div[@class="bootbox modal fade bootbox-confirm in"]')) rescue true }
      @wait.until { @driver.find_element(:xpath, '//div[@class="row row-center"]/div').text =~ /^#{per_page}/ }
    end

    it_behaves_like '表示されている件数が正しいこと', per_page, 1, per_page
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like '収支情報の数が正しいこと', per_page
    it_behaves_like '背景色が正しいこと'
  end

  describe '2ページ目にアクセスする' do
    include_context 'リセットボタンを押す'
    include_context '収支情報を入力する', default_inputs, 'income'
    include_context '登録ボタンを押す'
    before(:all) do
      @wait.until { @driver.find_element(:xpath, '//div[@class="row row-center"]/div').text =~ /^#{per_page + 1}/ }
      @driver.find_element(:xpath, '//span[@class="next"]').click
      @wait.until { URI.parse(@driver.current_url).query == 'page=2' }
    end

    it_behaves_like '表示されている件数が正しいこと', per_page + 1, per_page + 1, per_page + 1
    it_behaves_like 'ページングボタンが表示されていること'
    it_behaves_like '収支情報の数が正しいこと', 1
    it_behaves_like '背景色が正しいこと'
  end

  describe '10000円以下の収支情報を検索する' do
    before(:all) do
      @driver.find_element(:name, 'price_lower').send_keys('10000')
      @driver.find_element(:id, 'search_button').click
    end

    it_behaves_like 'URLにクエリがセットされていること', :price_lower => 10000
    it_behaves_like '表示されている件数が正しいこと', per_page + 1, 1, per_page
    it_behaves_like 'ページングボタンが表示されていること'
    it_behaves_like '収支情報の数が正しいこと', 50
    it_behaves_like '背景色が正しいこと'
    it_behaves_like 'フォームに値がセットされていること', :name => 'price_lower', :value => '10000'
  end

  describe '1000円以上10000円以下の収支情報を検索する' do
    before(:all) do
      @driver.find_element(:name, 'price_upper').send_keys('1000')
      @driver.find_element(:id, 'search_button').click
    end

    it_behaves_like 'URLにクエリがセットされていること', :price_upper => 1000, :price_lower => 10000
    it_behaves_like '表示されている件数が正しいこと', 0, 0, 0
    it_behaves_like 'ページングボタンが表示されていないこと'
    it_behaves_like '収支情報の数が正しいこと', 0
    it_behaves_like 'フォームに値がセットされていること', :name => 'price_lower', :value => '10000'
    it_behaves_like 'フォームに値がセットされていること', :name => 'price_upper', :value => '1000'
  end

  describe 'カレンダーを表示する' do
    before(:all) { @driver.find_element(:id, 'payments_date').click }
    after(:all) { @driver.find_element(:class, 'today').click }

    it 'カレンダーが表示されていること' do
      is_asserted_by { @driver.find_element(:class, 'bootstrap-datetimepicker-widget') }
    end
  end

  describe 'カテゴリ一覧を確認する' do
    before(:all) do
      @driver.find_element(:xpath, '//span[@id="category-list"]/button').click
      sleep 1
    end

    it 'カテゴリ一覧が表示されていること' do
      is_asserted_by { @driver.find_element(:xpath, '//div[@class="bootbox modal fade bootbox-prompt in"]') }
    end
  end
end
