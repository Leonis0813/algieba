# coding: utf-8
require 'rails_helper'

describe 'payments/index', :type => :view do
  per_page = 1
  param = {:date => '1000-01-01', :content => 'モジュールテスト用データ', :price => 100}
  main_content_xpath = '//div[@id="main-content"]'
  payment_list_xpath = "#{main_content_xpath}/div[@class='row center-block']/div[@class='col-lg-8']"

  shared_context 'HTML初期化' do
    before(:all) { @html = nil }
  end

  shared_context '収支情報を登録する' do |num|
    before(:all) do
      num.times { Payment.create!(param.merge(:payment_type => ['income', 'expense'].sample)) }
      @payments = Payment.order(:date => :desc).page(1)
    end

    after(:all) { Payment.destroy_all }
  end

  shared_examples '登録フォームが表示されていること' do
    register_form_xpath = [
      main_content_xpath,
      'div[@class="row center-block"]',
      'div[@class="col-lg-4"]',
      'div[@class="tab-content"]',
      'div[@id="new-payment"][@class="well tab-pane active"]',
    ].join('/')

    it 'タブが表示されていること' do
      expect(@html).to have_selector("#{main_content_xpath}/div/div/ul/li[@class='active']/a[@href='#new-payment']", :text => '登録')
    end

    it 'タイトルが表示されていること' do
      expect(@html).to have_selector("#{register_form_xpath}/h3", :text => '収支情報を入力してください')
    end

    it '日付入力フォームが表示されていること' do
      date_xpath = "#{register_form_xpath}/form[@id='new_payments']/div[@class='form-group']"
      expect(@html).to have_selector("#{date_xpath}/label", :text => '日付')
      expect(@html).to have_selector("#{date_xpath}/input[@id='payments_date']")
    end

    it '内容入力フォームが表示されていること' do
      content_xpath = "#{register_form_xpath}/form[@id='new_payments']/div[@class='form-group']"
      expect(@html).to have_selector("#{content_xpath}/label", :text => '内容')
      expect(@html).to have_selector("#{content_xpath}/input[@id='payments_content']")
    end

    it 'カテゴリ入力フォームが表示されていること' do
      category_xpath = "#{register_form_xpath}/form[@id='new_payments']/div[@class='form-group']"
      expect(@html).to have_selector("#{category_xpath}/label", :text => 'カテゴリ')
      expect(@html).to have_selector("#{category_xpath}/input[@id='payments_categories']")
      expect(@html).to have_selector("#{category_xpath}/span[@class='category-list']/button/span[@class='glyphicon glyphicon-list']")
    end

    it '金額入力フォームが表示されていること' do
      price_xpath = "#{register_form_xpath}/form[@id='new_payments']/div[@class='form-group']"
      expect(@html).to have_selector("#{price_xpath}/label", :text => '金額')
      expect(@html).to have_selector("#{price_xpath}/input[@id='payments_price']")
    end

    it '種類選択ボタンが表示されていること' do
      payment_type_xpath = "#{register_form_xpath}/form[@id='new_payments']/div[@class='form-group']"
      expect(@html).to have_selector("#{payment_type_xpath}/label", :text => '種類')
      expect(@html).to have_selector("#{payment_type_xpath}/span/label", :text => '収入')
      expect(@html).to have_selector("#{payment_type_xpath}/span/input[@value='income']")
      expect(@html).to have_selector("#{payment_type_xpath}/span/label", :text => '支出')
      expect(@html).to have_selector("#{payment_type_xpath}/span/input[@value='expense']")
    end

    it '検索ボタンが表示されていること' do
      expect(@html).to have_selector("#{register_form_xpath}/form[@id='new_payments']/input[@value='登録']")
    end
  end

  shared_examples '検索フォームが表示されていること' do
    search_form_xpath = [
      main_content_xpath,
      'div[@class="row center-block"]',
      'div[@class="col-lg-4"]',
      'div[@class="tab-content"]',
      'div[@id="search-form"][@class="well tab-pane"]',
    ].join('/')

    it 'タブが表示されていること' do
      expect(@html).to have_selector("#{main_content_xpath}/div/div/ul/li/a[@href='#search-form']", :text => '検索')
    end

    it 'タイトルが表示されていること' do
      expect(@html).to have_selector("#{search_form_xpath}/h3", :text => '検索条件を入力してください')
    end

    it '日付入力フォームが表示されていること' do
      date_xpath = "#{search_form_xpath}/form[@id='new_query']/div[@class='form-group']"
      expect(@html).to have_selector("#{date_xpath}/label", :text => '日付')
      expect(@html).to have_selector("#{date_xpath}/input[@id='query_date_after']")
      expect(@html).to have_selector("#{date_xpath}/input[@id='query_date_before']")
    end

    it '内容入力フォームが表示されていること' do
      content_xpath = "#{search_form_xpath}/form[@id='new_query']/div[@class='form-group']"
      expect(@html).to have_selector("#{content_xpath}/label", :text => '内容')
      expect(@html).to have_selector("#{content_xpath}/input[@id='content']")

      select_xpath = "#{content_xpath}/select[@id='content-type']"
      expect(@html).to have_selector("#{select_xpath}/option[@value='include'][@selected]", :text => 'を含む')
      expect(@html).to have_selector("#{select_xpath}/option[@value='equal']", :text => 'と一致する')
    end

    it 'カテゴリ入力フォームが表示されていること' do
      category_xpath = "#{search_form_xpath}/form[@id='new_query']/div[@class='form-group']"
      expect(@html).to have_selector("#{category_xpath}/label", :text => 'カテゴリ')
      expect(@html).to have_selector("#{category_xpath}/input[@id='query_category']")
      expect(@html).to have_selector("#{category_xpath}/span[@class='category-list']/button/span[@class='glyphicon glyphicon-list']")
    end

    it '金額入力フォームが表示されていること' do
      price_xpath = "#{search_form_xpath}/form[@id='new_query']/div[@class='form-group']"
      expect(@html).to have_selector("#{price_xpath}/label", :text => '金額')
      expect(@html).to have_selector("#{price_xpath}/input[@id='query_price_upper']")
      expect(@html).to have_selector("#{price_xpath}/input[@id='query_price_lower']")
    end

    it '種類選択ボタンが表示されていること' do
      payment_type_xpath = "#{search_form_xpath}/form[@id='new_query']/div[@class='form-group']"
      expect(@html).to have_selector("#{payment_type_xpath}/label", :text => '種類')

      select_xpath = "#{payment_type_xpath}/select[@id='query_payment_type']"
      expect(@html).to have_selector("#{select_xpath}/option", :text => '')
      expect(@html).to have_selector("#{select_xpath}/option[@value='income']", :text => '収入')
      expect(@html).to have_selector("#{select_xpath}/option[@value='expense']", :text => '支出')
    end

    it '検索ボタンが表示されていること' do
      expect(@html).to have_selector("#{search_form_xpath}/form[@id='new_query']/input[@id='search-button']")
    end
  end

  shared_examples '件数情報が表示されていること' do |total: 0, from: 0, to: 0|
    it do
      info_xpath = "#{payment_list_xpath}/div/h4"
      expect(@html).to have_selector(info_xpath, :text => "#{total}件中#{from}〜#{to}件を表示")
    end
  end

  shared_examples 'ページングが表示されていないこと' do
    it do
      paging_xpath = "#{payment_list_xpath}/span/nav[@class='pagination']"
      expect(@html).not_to have_selector(paging_xpath)
    end
  end

  shared_examples 'ページングが表示されていること' do
    paging_xpath = "#{payment_list_xpath}/nav[@class='pagination']"

    it 'ページングボタンが表示されていること' do
      expect(@html).to have_selector(paging_xpath)
    end

    it '先頭のページへのボタンが表示されていないこと' do
      expect(@html).not_to have_selector("#{paging_xpath}/li/span[@class='first']/a", :text => I18n.t('views.list.pagination.first'))
    end

    it '前のページへのボタンが表示されていないこと' do
      expect(@html).not_to have_selector("#{paging_xpath}/li/span[@class='prev']/a", :text => I18n.t('views.list.pagination.previous'))
    end

    it '1ページ目が表示されていること' do
      expect(@html).to have_selector("#{paging_xpath}/li/span[@class='page current']", :text => 1)
    end

    it '2ページ目が表示されていること' do
      expect(@html).to have_selector("#{paging_xpath}/li/span[@class='page']/a[href='/payments?page=2']", :text => 2)
    end

    it '次のページへのボタンが表示されていること' do
      expect(@html).to have_selector("#{paging_xpath}/li/span[@class='next']/a[href='/payments?page=2']", :text => I18n.t('views.list.pagination.next'))
    end

    it '最後のページへのボタンが表示されていること' do
      expect(@html).to have_selector("#{paging_xpath}/li/span[@class='last']/a", :text => I18n.t('views.list.pagination.last'))
    end
  end

  shared_examples '表示件数が表示されていること' do
    it do
      per_page_xpath = "#{payment_list_xpath}/div/form[@id='per_page_form']"
      expect(@html).to have_selector(per_page_xpath)
    end
  end

  shared_examples 'テーブルのヘッダーが表示されていること' do
    table_header_xpath = "#{payment_list_xpath}//table[@id='payment_table']/thead/tr/th"

    %w[ 種類 日付 内容 カテゴリ 金額 ].each do |attribute|
      it "#{attribute}のヘッダーが表示されていること" do
        expect(@html).to have_selector(table_header_xpath, :text => attribute)
      end
    end
  end

  shared_examples 'テーブルに表示されているデータが正しいこと' do |expected_size: 0|
    it 'データの数が正しいこと' do
      table_body_xpath = "#{payment_list_xpath}//table[@id='payment_table']/tbody/tr"
      expect(@html).to have_xpath(table_body_xpath, :count => expected_size)
    end

    it '背景色が正しいこと', :if => expected_size > 0 do
      matched_data = @html.gsub("\n", '').match(/<td\s*class='(?<color>.*?)'\s*>(?<payment_type>.*?)<\/td>/)
      case matched_data[:payment_type]
      when I18n.t('views.payment.income')
        is_asserted_by { matched_data[:color] == 'success' }
      when I18n.t('views.payment.expense')
        is_asserted_by { matched_data[:color] == 'danger' }
      end
    end
  end

  before(:all) do
    @html = nil
    @payment = Payment.new
    @search_form = Query.new
    Kaminari.config.default_per_page = per_page
  end

  before(:each) do
    render :template => 'payments/index', :layout => 'layouts/application'
    @html ||= response
  end

  after(:all) { Category.destroy_all }

  describe '収支情報が0件の場合' do
    include_context 'HTML初期化'
    include_context '収支情報を登録する', 0

    it_behaves_like 'ヘッダーが表示されていること'
    it_behaves_like '登録フォームが表示されていること'
    it_behaves_like '検索フォームが表示されていること'
    it_behaves_like '件数情報が表示されていること'
    it_behaves_like 'ページングが表示されていないこと'
    it_behaves_like '表示件数が表示されていること'
    it_behaves_like 'テーブルのヘッダーが表示されていること'
    it_behaves_like 'テーブルに表示されているデータが正しいこと'
  end

  describe "収支情報が#{per_page}件の場合" do
    include_context 'HTML初期化'
    include_context '収支情報を登録する', per_page

    it_behaves_like 'ヘッダーが表示されていること'
    it_behaves_like '登録フォームが表示されていること'
    it_behaves_like '検索フォームが表示されていること'
    it_behaves_like '件数情報が表示されていること', :total => per_page, :from => 1, :to => per_page
    it_behaves_like 'ページングが表示されていないこと'
    it_behaves_like '表示件数が表示されていること'
    it_behaves_like 'テーブルのヘッダーが表示されていること'
    it_behaves_like 'テーブルに表示されているデータが正しいこと', :expected_size => per_page
  end

  describe "収支情報が#{per_page + 1}件の場合" do
    include_context 'HTML初期化'
    include_context '収支情報を登録する', per_page + 1

    it_behaves_like 'ヘッダーが表示されていること'
    it_behaves_like '登録フォームが表示されていること'
    it_behaves_like '検索フォームが表示されていること'
    it_behaves_like '件数情報が表示されていること', :total => per_page + 1, :from => 1, :to => per_page
    it_behaves_like 'ページングが表示されていること'
    it_behaves_like '表示件数が表示されていること'
    it_behaves_like 'テーブルのヘッダーが表示されていること'
    it_behaves_like 'テーブルに表示されているデータが正しいこと', :expected_size => per_page
  end

  describe "収支情報が#{per_page + Kaminari.config.window * 2 + 1}件の場合" do
    total = per_page + Kaminari.config.window * 2 + 1
    include_context 'HTML初期化'
    include_context '収支情報を登録する', total

    it_behaves_like 'ヘッダーが表示されていること'
    it_behaves_like '登録フォームが表示されていること'
    it_behaves_like '検索フォームが表示されていること'
    it_behaves_like '件数情報が表示されていること', :total => total, :from => 1, :to => per_page
    it_behaves_like 'ページングが表示されていること'
    it_behaves_like '表示件数が表示されていること'
    it_behaves_like 'テーブルのヘッダーが表示されていること'
    it_behaves_like 'テーブルに表示されているデータが正しいこと', :expected_size => per_page
  end
end
