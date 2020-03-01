# coding: utf-8

require 'rails_helper'

describe 'dictionaries/index', type: :view do
  per_page = 1
  main_content_xpath = '//div[@id="main-content"]'
  dictionary_list_xpath =
    "#{main_content_xpath}/div[@class='row center-block']/div[@class='col-lg-8']"

  shared_context '辞書情報を登録する' do |num|
    before(:all) do
      num.times do |i|
        category_name = "category#{i}"
        category = create(:category, name: category_name)
        create(:dictionary, phrase: "phrase#{i}", categories: [category])
      end

      @dictionaries = Dictionary.order(:phrase).page(1)
    end
  end

  shared_examples '画面共通テスト' do |expected: {}|
    it_behaves_like 'ヘッダーが表示されていること'
    it_behaves_like '登録フォームが表示されていること'
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
      'div[@id="new-dictionary"][@class="well tab-pane active"]',
    ].join('/')

    form_base_xpath = [
      create_form_xpath,
      'form[@id="new_dictionary"]',
      'div[@class="form-group"]',
    ].join('/')

    it 'タブが表示されていること' do
      xpath =
        "#{main_content_xpath}/div/div/ul/li[@class='active']/a[@href='#new-dictionary']"
      tab = @html.xpath(xpath)
      is_asserted_by { tab.present? }
      is_asserted_by { tab.text.strip == '登録' }
    end

    it 'タイトルが表示されていること' do
      title = @html.xpath("#{create_form_xpath}/h3")
      is_asserted_by { title.present? }
      is_asserted_by { title.text.strip == '辞書情報を入力してください' }
    end

    it 'フレーズ入力フォームが表示されていること' do
      phrase_label = @html.xpath("#{form_base_xpath}/label[@for='phrase']")
      is_asserted_by { phrase_label.present? }
      is_asserted_by { phrase_label.text.strip == 'フレーズ' }

      phrase_input = @html.xpath("#{form_base_xpath}/input[@id='phrase']")
      is_asserted_by { phrase_input.present? }
    end

    it '条件を選択するセレクトボックスが表示されていること' do
      condition_select_xpath = "#{form_base_xpath}/select"

      [
        ['include', 'を含む'],
        ['equal', 'と一致する'],
      ].each do |value, text|
        condition_option = @html.xpath("#{condition_select_xpath}/option[@value='#{value}']")
        is_asserted_by { condition_option.present? }
        is_asserted_by { condition_option.text.strip == text }
      end
    end

    it 'カテゴリ入力フォームが表示されていること' do
      categories_label = @html.xpath("#{form_base_xpath}/label[@for='dictionary_categories']")
      is_asserted_by { categories_label.present? }
      is_asserted_by { categories_label.text.strip == 'カテゴリ' }

      categories_input = @html.xpath("#{form_base_xpath}/input[@id='dictionary_categories']")
      is_asserted_by { categories_input.present? }

      categories_button = @html.xpath("#{form_base_xpath}/span[@class='category-list']" \
                                      '/button/span[@class="glyphicon glyphicon-list"]')
      is_asserted_by { categories_button.present? }
    end

    it '登録ボタンが表示されていること' do
      xpath = "#{create_form_xpath}/form[@id='new_dictionary']/input[@value='登録']"
      is_asserted_by { @html.xpath(xpath).present? }
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
      'form[@id="new_dictionary_query"]',
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

    it 'フレーズ入力フォームが表示されていること' do
      phrase_label = @html.xpath("#{form_base_xpath}/label[@for='phrase_include']")
      is_asserted_by { phrase_label.present? }
      is_asserted_by { phrase_label.text.strip == 'フレーズ' }

      phrase_input = @html.xpath("#{form_base_xpath}/input[@id='phrase_include']")
      is_asserted_by { phrase_input.present? }
    end

    it '検索ボタンが表示されていること' do
      search_button = @html.xpath("#{search_form_xpath}/form[@id='new_dictionary_query']" \
                                  '/input[@id="dictionary-search-button"][@value="検索"]')
      is_asserted_by { search_button.present? }
    end
  end

  shared_examples '件数情報が表示されていること' do |total: 0, from: 0, to: 0|
    it do
      info = @html.xpath("#{dictionary_list_xpath}/div/h4")
      is_asserted_by { info.present? }
      is_asserted_by { info.text.strip == "#{total}件中#{from}〜#{to}件を表示" }
    end
  end

  shared_examples 'ページングが表示されていないこと' do
    it do
      paging = @html.xpath("#{dictionary_list_xpath}/span/nav[@class='pagination']")
      is_asserted_by { paging.blank? }
    end
  end

  shared_examples 'ページングが表示されていること' do
    paging_xpath = "#{dictionary_list_xpath}/nav[@class='pagination']"

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
                             '/a[@href="/management/dictionaries?page=2"]')
      is_asserted_by { two_link.present? }
      is_asserted_by { two_link.text == '2' }
    end

    it '次のページへのボタンが表示されていること' do
      next_link = @html.xpath("#{paging_xpath}/li/span[@class='next']" \
                              '/a[@href="/management/dictionaries?page=2"]')
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
      per_page_xpath = "#{dictionary_list_xpath}/div/form[@id='per_page_form']"
      is_asserted_by { @html.xpath(per_page_xpath).present? }
    end
  end

  shared_examples 'テーブルのヘッダーが表示されていること' do
    table_header_xpath = "#{dictionary_list_xpath}/table[@id='table-dictionary']/thead/tr/th"

    %w[フレーズ 条件 カテゴリ].each_with_index do |text, i|
      it "#{text}のヘッダーが表示されていること" do
        headers = @html.xpath(table_header_xpath)
        is_asserted_by { headers[i].present? }
        is_asserted_by { headers[i].text.strip == text }
      end
    end
  end

  shared_examples 'テーブルに表示されている辞書が正しいこと' do |expected_size: 0|
    before(:each) do
      table_body_xpath = "#{dictionary_list_xpath}/table[@id='table-dictionary']/tbody/tr"
      @table_rows = @html.xpath(table_body_xpath)
    end


    expected_size.times do |i|
      it do
        phrase, condition, categories = @table_rows[i].search('td')
        is_asserted_by { phrase.text.strip == @dictionaries[i].phrase }

        condition_i18n_path = [
          'views.management.dictionaries.form.create.condition',
          @dictionaries[i].condition,
        ].join('.')
        is_asserted_by { condition.text.strip == I18n.t(condition_i18n_path) }

        is_asserted_by do
          categories.text.strip == @dictionaries[i].categories.pluck(:name).join(',')
        end
      end
    end
  end

  before(:all) do
    @dictionary = Dictionary.new
    @search_form = DictionaryQuery.new
    Kaminari.config.default_per_page = per_page
  end

  before(:each) do
    render template: 'dictionaries/index', layout: 'layouts/application'
    @html ||= Nokogiri.parse(response)
  end

  describe '辞書情報が0件の場合' do
    include_context 'HTML初期化'
    include_context 'トランザクション作成'
    include_context '辞書情報を登録する', 0

    it_behaves_like '画面共通テスト'
    it_behaves_like 'ページングが表示されていないこと'
    it_behaves_like '表示件数が表示されていること'
    it_behaves_like 'テーブルのヘッダーが表示されていること'
    it_behaves_like 'テーブルに表示されている辞書が正しいこと'
  end

  describe "辞書情報が#{per_page}件の場合" do
    expected = {size: per_page, total: per_page, from: 1, to: per_page}
    include_context 'HTML初期化'
    include_context 'トランザクション作成'
    include_context '辞書情報を登録する', per_page

    it_behaves_like '画面共通テスト', expected: expected
    it_behaves_like 'ページングが表示されていないこと'
    it_behaves_like '表示件数が表示されていること'
    it_behaves_like 'テーブルのヘッダーが表示されていること'
    it_behaves_like 'テーブルに表示されている辞書が正しいこと', expected_size: per_page
  end

  describe "辞書情報が#{per_page + 1}件の場合" do
    expected = {size: per_page, total: per_page + 1, from: 1, to: per_page}
    include_context 'HTML初期化'
    include_context 'トランザクション作成'
    include_context '辞書情報を登録する', per_page + 1

    it_behaves_like '画面共通テスト', expected: expected
    it_behaves_like 'ページングが表示されていること'
    it_behaves_like '表示件数が表示されていること'
    it_behaves_like 'テーブルのヘッダーが表示されていること'
    it_behaves_like 'テーブルに表示されている辞書が正しいこと', expected_size: per_page
  end

  describe "辞書情報が#{per_page + Kaminari.config.window * 2 + 1}件の場合" do
    total = per_page + Kaminari.config.window * 2 + 1
    expected = {size: per_page, total: total, from: 1, to: per_page}
    include_context 'HTML初期化'
    include_context 'トランザクション作成'
    include_context '辞書情報を登録する', total

    it_behaves_like '画面共通テスト', expected: expected
    it_behaves_like 'ページングが表示されていること'
    it_behaves_like '表示件数が表示されていること'
    it_behaves_like 'テーブルのヘッダーが表示されていること'
    it_behaves_like 'テーブルに表示されている辞書が正しいこと', expected_size: per_page
  end
end
