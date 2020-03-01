# coding: utf-8

require 'rails_helper'

describe 'tags/index', type: :view do
  per_page = 1
  param = {date: '1000-01-01', content: 'モジュールテスト用データ', price: 100}
  main_content_xpath = '//div[@id="main-content"]'
  payment_list_xpath =
    "#{main_content_xpath}/div[@class='row center-block']/div[@class='col-lg-8']"

  shared_context 'タグ情報を登録する' do |num|
    before(:all) do
      payment = create(:payment, tags: [])
      num.times {|i| create(:tag, name: "tag#{i}", payments: [payment]) }
      @tags = Tag.order(:name).page(1)
    end
  end

  shared_examples '画面共通テスト' do |expected: {}|
    it_behaves_like 'ヘッダーが表示されていること'
    it_behaves_like '登録フォームが表示されていること'
    it_behaves_like '設定フォームが表示されていること', expected[:size] || 0
    it_behaves_like '検索フォームが表示されていること'
    it_behaves_like '件数情報が表示されていること',
                    total: expected[:total] || 0,
                    from: expected[:from] || 0,
                    to: expected[:to] || 0
  end

  shared_examples '登録フォームが表示されていること' do
    create_form_xpath = [
      main_content_xpath,
      'div[@class="row center-block"]',
      'div[@class="col-lg-4"]',
      'div[@class="tab-content"]',
      'div[@id="create-form"][@class="well tab-pane active"]',
    ].join('/')

    form_base_xpath = [
      create_form_xpath,
      'form[@id="new_tag"]',
      'div[@class="form-group"]',
    ].join('/')

    it 'タブが表示されていること' do
      xpath =
        "#{main_content_xpath}/div/div/ul/li[@class='active']/a[@href='#create-form']"
      tab = @html.xpath(xpath)
      is_asserted_by { tab.present? }
      is_asserted_by { tab.text.strip == '登録' }
    end

    it 'タイトルが表示されていること' do
      title = @html.xpath("#{create_form_xpath}/h3")
      is_asserted_by { title.present? }
      is_asserted_by { title.text.strip == 'タグ名を入力してください' }
    end

    it '名前入力フォームが表示されていること' do
      name_label = @html.xpath("#{form_base_xpath}/label[@for='name']")
      is_asserted_by { name_label.present? }
      is_asserted_by { name_label.text.strip == '名前' }

      name_input = @html.xpath("#{form_base_xpath}/input[@id='name']")
      is_asserted_by { name_input.present? }
    end

    it '登録ボタンが表示されていること' do
      create_button = @html.xpath("#{create_form_xpath}/form[@id='new_tag']" \
                                  '/input[@value="登録"]')
      is_asserted_by { create_button.present? }
    end
  end

  shared_examples '設定フォームが表示されていること' do
    assign_form_xpath = [
      main_content_xpath,
      'div[@class="row center-block"]',
      'div[@class="col-lg-4"]',
      'div[@class="tab-content"]',
      'div[@id="assign-form"][@class="well tab-pane"]',
    ].join('/')

    form_base_xpath = [
      assign_form_xpath,
      'div[@class="form-group"]',
    ].join('/')

    it 'タブが表示されていること' do
      xpath =
        "#{main_content_xpath}/div/div/ul/li/a[@href='#assign-form']"
      tab = @html.xpath(xpath)
      is_asserted_by { tab.present? }
      is_asserted_by { tab.text.strip == '設定' }
    end

    it 'タイトルが表示されていること' do
      title = @html.xpath("#{assign_form_xpath}/h3")
      is_asserted_by { title.present? }
      is_asserted_by { title.text.strip == '設定するタグと収支情報を入力してください' }
    end

    it '内容入力フォームが表示されていること' do
      content_label = @html.xpath("#{form_base_xpath}/label[@for='content_include']")
      is_asserted_by { content_label.present? }
      is_asserted_by { content_label.text.strip == '内容' }

      content_input = @html.xpath("#{form_base_xpath}/input[@id='content_include']")
      is_asserted_by { content_input.present? }
    end

    it 'タグ入力フォームが表示されていること' do
      tag_label = @html.xpath("#{form_base_xpath}/label[@for='tag']")
      is_asserted_by { tag_label.present? }
      is_asserted_by { tag_label.text.strip == 'タグ' }

      tag_input = @html.xpath("#{form_base_xpath}/input[@id='tag'][@readonly='readonly']")
      is_asserted_by { tag_input.present? }

      tag_button = @html.xpath("#{form_base_xpath}/span[@class='tag-list']" \
                               '/button/span[@class="glyphicon glyphicon-list"]')
      is_asserted_by { tag_button.present? }
    end

    it '設定ボタンが表示されていること' do
      assign_button = @html.xpath("#{assign_form_xpath}/button[@id='btn-assign-tag']")
      is_asserted_by { assign_button.present? }
      is_asserted_by { assign_button.text.strip == '設定' }
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

    form_base_xpath = [
      search_form_xpath,
      'form[@id="new_tag_query"]',
      'div[@class="form-group"]',
    ].join('/')

    it 'タブが表示されていること' do
      tab = @html.xpath("#{main_content_xpath}/div/div/ul/li/a[@href='#search-form']")
      is_asserted_by { tab.present? }
      is_asserted_by { tab.text.strip == '検索' }
    end

    it 'タイトルが表示されていること' do
      title = @html.xpath("#{search_form_xpath}/h3")
      is_asserted_by { title.present? }
      is_asserted_by { title.text.strip == '検索条件を入力してください' }
    end

    it '内容入力フォームが表示されていること' do
      name_label = @html.xpath("#{form_base_xpath}/label[@for='name_include']")
      is_asserted_by { name_label.present? }
      is_asserted_by { name_label.text.strip == '名前' }

      name_input = @html.xpath("#{form_base_xpath}/input[@id='name_include']")
      is_asserted_by { name_input.present? }
    end

    it '検索ボタンが表示されていること' do
      search_button = @html.xpath("#{search_form_xpath}/form[@id='new_tag_query']/input[@id='tag-search-button']")
      is_asserted_by { search_button.present? }
    end
  end

  shared_examples '件数情報が表示されていること' do |total: 0, from: 0, to: 0|
    it do
      info = @html.xpath("#{payment_list_xpath}/div/h4")
      is_asserted_by { info.present? }
      is_asserted_by { info.text.strip == "#{total}件中#{from}〜#{to}件を表示" }
    end
  end

  shared_examples 'ページングが表示されていないこと' do
    it do
      paging = @html.xpath("#{payment_list_xpath}/span/nav[@class='pagination']")
      is_asserted_by { paging.blank? }
    end
  end

  shared_examples 'ページングが表示されていること' do
    paging_xpath = "#{payment_list_xpath}/nav[@class='pagination']"

    it 'ページングボタンが表示されていること' do
      is_asserted_by { @html.xpath(paging_xpath).present? }
    end

    it '先頭のページへのボタンが表示されていないこと' do
      first_link = @html.xpath("#{paging_xpath}/li/span[@class='first']/a")
      is_asserted_by { first_link.blank? }
    end

    it '前のページへのボタンが表示されていないこと' do
      prev_link = @html.xpath("#{paging_xpath}/li/span[@class='prev']/a")
      is_asserted_by { prev_link.blank? }
    end

    it '1ページ目が表示されていること' do
      one_link = @html.xpath("#{paging_xpath}/li/span[@class='page current']")
      is_asserted_by { one_link.present? }
      is_asserted_by { one_link.text.strip == '1' }
    end

    it '2ページ目が表示されていること' do
      two_link = @html.xpath("#{paging_xpath}/li/span[@class='page']" \
                             '/a[@href="/management/tags?page=2"]')
      is_asserted_by { two_link.present? }
      is_asserted_by { two_link.text == '2' }
    end

    it '次のページへのボタンが表示されていること' do
      next_link = @html.xpath("#{paging_xpath}/li/span[@class='next']" \
                              '/a[@href="/management/tags?page=2"]')
      is_asserted_by { next_link.present? }
      is_asserted_by { next_link.text == I18n.t('views.management.common..pagination.next') }
    end

    it '最後のページへのボタンが表示されていること' do
      last_link = @html.xpath("#{paging_xpath}/li/span[@class='last']/a")
      is_asserted_by { last_link.present? }
      is_asserted_by { last_link.text == I18n.t('views.management.common.pagination.last') }
    end
  end

  shared_examples '表示件数が表示されていること' do
    it do
      per_page_xpath = "#{payment_list_xpath}/div/form[@id='per_page_form']"
      is_asserted_by { @html.xpath(per_page_xpath).present? }
    end
  end

  shared_examples 'テーブルのヘッダーが表示されていること' do
    table_header_xpath = "#{payment_list_xpath}//table[@id='table-tag']/thead/tr/th"

    %w[名前].each_with_index do |text, i|
      it "#{text}のヘッダーが表示されていること" do
        headers = @html.xpath(table_header_xpath)
        is_asserted_by { headers[i].present? }
        is_asserted_by { headers[i].text.strip == text }
      end
    end
  end

  shared_examples 'テーブルに表示されているタグが正しいこと' do |expected_size: 0|
    before(:each) do
      table_body_xpath = "#{payment_list_xpath}/table[@id='table-tag']/tbody/tr"
      @table_rows = @html.xpath(table_body_xpath)
    end

    expected_size.times do |i|
      it do
        name = @table_rows[i].search('td')
        is_asserted_by { name.text.strip == @tags[i].name }
      end
    end
  end

  before(:all) do
    @tag = Tag.new
    @search_form = TagQuery.new
    Kaminari.config.default_per_page = per_page
  end

  before(:each) do
    render template: 'tags/index', layout: 'layouts/application'
    @html ||= Nokogiri.parse(response)
  end

  describe 'タグ情報が0件の場合' do
    include_context 'HTML初期化'
    include_context 'トランザクション作成'
    include_context 'タグ情報を登録する', 0

    it_behaves_like '画面共通テスト'
    it_behaves_like 'ページングが表示されていないこと'
    it_behaves_like '表示件数が表示されていること'
    it_behaves_like 'テーブルのヘッダーが表示されていること'
    it_behaves_like 'テーブルに表示されているタグが正しいこと'
  end

  describe "タグ情報が#{per_page}件の場合" do
    expected = {size: per_page, total: per_page, from: 1, to: per_page}
    include_context 'HTML初期化'
    include_context 'トランザクション作成'
    include_context 'タグ情報を登録する', per_page

    it_behaves_like '画面共通テスト', expected: expected
    it_behaves_like 'ページングが表示されていないこと'
    it_behaves_like '表示件数が表示されていること'
    it_behaves_like 'テーブルのヘッダーが表示されていること'
    it_behaves_like 'テーブルに表示されているタグが正しいこと', expected_size: per_page
  end

  describe "タグ情報が#{per_page + 1}件の場合" do
    expected = {size: per_page, total: per_page + 1, from: 1, to: per_page}
    include_context 'HTML初期化'
    include_context 'トランザクション作成'
    include_context 'タグ情報を登録する', per_page + 1

    it_behaves_like '画面共通テスト', expected: expected
    it_behaves_like 'ページングが表示されていること'
    it_behaves_like '表示件数が表示されていること'
    it_behaves_like 'テーブルのヘッダーが表示されていること'
    it_behaves_like 'テーブルに表示されているタグが正しいこと', expected_size: per_page
  end

  describe "タグ情報が#{per_page + Kaminari.config.window * 2 + 1}件の場合" do
    total = per_page + Kaminari.config.window * 2 + 1
    expected = {size: per_page, total: total, from: 1, to: per_page}
    include_context 'HTML初期化'
    include_context 'トランザクション作成'
    include_context 'タグ情報を登録する', total

    it_behaves_like '画面共通テスト', expected: expected
    it_behaves_like 'ページングが表示されていること'
    it_behaves_like '表示件数が表示されていること'
    it_behaves_like 'テーブルのヘッダーが表示されていること'
    it_behaves_like 'テーブルに表示されているタグが正しいこと', expected_size: per_page
  end
end
