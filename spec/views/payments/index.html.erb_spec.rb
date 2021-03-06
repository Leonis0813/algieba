# coding: utf-8

require 'rails_helper'

describe 'payments/index', type: :view do
  per_page = 1
  param = {date: '1000-01-01', content: 'モジュールテスト用データ', price: 100}
  main_content_xpath = '//div[@id="main-content"]'
  payment_list_xpath =
    "#{main_content_xpath}/div[@class='row center-block']/div[@class='col-lg-8']"

  shared_context '収支情報を登録する' do |num|
    before(:all) do
      @category = Array.new(2) do |i|
        name = "category#{i}"
        create(:category, name: name)
        [name, 0]
      end.to_h

      num.times do
        payment = Payment.new(param.merge(payment_type: %w[income expense].sample))
        category = Category.first
        @category[category.name] += 1
        payment.categories << [category]
        payment.save!
      end

      @payments = Payment.order(date: :desc).page(1)
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
    it_behaves_like 'タグ設定ボタンが表示されていること'
  end

  shared_examples '登録フォームが表示されていること' do
    register_form_xpath = [
      main_content_xpath,
      'div[@class="row center-block"]',
      'div[@class="col-lg-4"]',
      'div[@class="tab-content"]',
      'div[@id="new-payment"][@class="well tab-pane active"]',
    ].join('/')

    form_base_xpath = [
      register_form_xpath,
      'form[@id="form-payment-create"]',
      'div[@class="form-group"]',
    ].join('/')

    it 'タブが表示されていること' do
      xpath =
        "#{main_content_xpath}/div/div/ul/li[@class='active']/a[@href='#new-payment']"
      tab = @html.xpath(xpath)
      is_asserted_by { tab.present? }
      is_asserted_by { tab.text.strip == '登録' }
    end

    it 'タイトルが表示されていること' do
      title = @html.xpath("#{register_form_xpath}/h3")
      is_asserted_by { title.present? }
      is_asserted_by { title.text.strip == '収支情報を入力してください' }
    end

    it '必須項目の説明が表示されていること' do
      description = @html.xpath("#{register_form_xpath}/h4")
      is_asserted_by { description.present? }
      is_asserted_by { description.text.strip == '* は必須項目です' }
    end

    it '日付入力フォームが表示されていること' do
      label_xpath = "#{form_base_xpath}/label[text()='日付'][@class='required']"
      is_asserted_by { @html.xpath(label_xpath).present? }

      date_input = @html.xpath("#{form_base_xpath}/input[@id='payment_date']")
      is_asserted_by { date_input.present? }
    end

    it '内容入力フォームが表示されていること' do
      label_xpath = "#{form_base_xpath}/label[text()='内容'][@class='required']"
      is_asserted_by { @html.xpath(label_xpath).present? }

      content_input = @html.xpath("#{form_base_xpath}/input[@id='payment_content']")
      is_asserted_by { content_input.present? }
    end

    it 'カテゴリ入力フォームが表示されていること' do
      label_xpath = "#{form_base_xpath}/label[text()='カテゴリ'][@class='required']"
      is_asserted_by { @html.xpath(label_xpath).present? }

      category_input = @html.xpath("#{form_base_xpath}/input[@id='payment_categories']")
      is_asserted_by { category_input.present? }

      category_button = @html.xpath("#{form_base_xpath}/span[@class='category-list']" \
                                    '/button/span[@class="glyphicon glyphicon-list"]')
      is_asserted_by { category_button.present? }
    end

    it 'タグ入力フォームが表示されていること' do
      label_xpath = "#{form_base_xpath}/label[text()='タグ']"
      is_asserted_by { @html.xpath(label_xpath).present? }

      tag_input = @html.xpath("#{form_base_xpath}/input[@id='payment_tags']")
      is_asserted_by { tag_input.present? }
    end

    it '金額入力フォームが表示されていること' do
      price_label = @html.xpath("#{form_base_xpath}/label[text()='金額']")
      is_asserted_by { price_label.present? }

      price_input = @html.xpath("#{form_base_xpath}/input[@id='payment_price']")
      is_asserted_by { price_input.present? }
    end

    it '種類選択ボタンが表示されていること' do
      payment_type_label = @html.xpath("#{form_base_xpath}/label[text()='種類']")
      is_asserted_by { payment_type_label.present? }

      income_label = @html.xpath("#{form_base_xpath}/span/label[text()='収入']")
      is_asserted_by { income_label.present? }
      income_input = @html.xpath("#{form_base_xpath}/span/input[@value='income']")
      is_asserted_by { income_input.present? }

      expense_label = @html.xpath("#{form_base_xpath}/span/label[text()='支出']")
      is_asserted_by { expense_label.present? }
      expense_input = @html.xpath("#{form_base_xpath}/span/input[@value='expense']")
      is_asserted_by { expense_input.present? }
    end

    it '登録ボタンが表示されていること' do
      xpath = "#{register_form_xpath}/form[@id='form-payment-create']/" \
              'input[@value="登録"]'
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
      'form[@id="new_payment_query"]',
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

    it '日付入力フォームが表示されていること' do
      date_label = @html.xpath("#{form_base_xpath}/label[text()='日付']")
      is_asserted_by { date_label.present? }

      date_after =
        @html.xpath("#{form_base_xpath}/input[@id='payment_query_date_after']")
      is_asserted_by { date_after.present? }

      date_before =
        @html.xpath("#{form_base_xpath}/input[@id='payment_query_date_before']")
      is_asserted_by { date_before.present? }
    end

    it '内容入力フォームが表示されていること' do
      content_label = @html.xpath("#{form_base_xpath}/label[text()='内容']")
      is_asserted_by { content_label.present? }

      content_input = @html.xpath("#{form_base_xpath}/input[@id='content']")
      is_asserted_by { content_input.present? }

      select_xpath = "#{form_base_xpath}/select[@id='content-type']"
      content_include = @html.xpath("#{select_xpath}/option[@value='include']" \
                                    '[@selected][text()="を含む"]')
      is_asserted_by { content_include.present? }

      content_equal = @html.xpath("#{select_xpath}/option[@value='equal']" \
                                  '[text()="と一致する"]')
      is_asserted_by { content_equal.present? }
    end

    it 'カテゴリ入力フォームが表示されていること' do
      category_label = @html.xpath("#{form_base_xpath}/label[text()='カテゴリ']")
      is_asserted_by { category_label.present? }

      category_input =
        @html.xpath("#{form_base_xpath}/input[@id='payment_query_category']")
      is_asserted_by { category_input.present? }

      category_button = @html.xpath("#{form_base_xpath}/span[@class='category-list']" \
                                    '/button/span[@class="glyphicon glyphicon-list"]')
      is_asserted_by { category_button.present? }
    end

    it 'タグ入力フォームが表示されていること' do
      tag_label = @html.xpath("#{form_base_xpath}/label[text()='タグ']")
      is_asserted_by { tag_label.present? }

      tag_input_xpath =
        "#{form_base_xpath}/input[@id='payment_query_tag'][@readonly='readonly']"
      tag_input = @html.xpath(tag_input_xpath)
      is_asserted_by { tag_input.present? }

      tag_button = @html.xpath("#{form_base_xpath}/span[@class='tag-list']" \
                               '/button/span[@class="glyphicon glyphicon-list"]')
      is_asserted_by { tag_button.present? }
    end

    it '金額入力フォームが表示されていること' do
      price_label = @html.xpath("#{form_base_xpath}/label[text()='金額']")
      is_asserted_by { price_label.present? }

      price_upper =
        @html.xpath("#{form_base_xpath}/input[@id='payment_query_price_upper']")
      is_asserted_by { price_upper.present? }

      price_lower =
        @html.xpath("#{form_base_xpath}/input[@id='payment_query_price_lower']")
      is_asserted_by { price_lower.present? }
    end

    it '種類選択ボタンが表示されていること' do
      payment_type_label = @html.xpath("#{form_base_xpath}/label[text()='種類']")
      is_asserted_by { payment_type_label.present? }

      select_xpath = "#{form_base_xpath}/select[@id='payment_query_payment_type']"
      all = @html.xpath("#{select_xpath}/option[@value='']")
      is_asserted_by { all.present? }
      income = @html.xpath("#{select_xpath}/option[@value='income'][text()='収入']")
      is_asserted_by { income.present? }
      expense = @html.xpath("#{select_xpath}/option[@value='expense'][text()='支出']")
      is_asserted_by { expense.present? }
    end

    it '検索ボタンが表示されていること' do
      search_button = @html.xpath("#{search_form_xpath}/form[@id='new_payment_query']" \
                                  '/input[@id="btn-payment-search"]')
      is_asserted_by { search_button.present? }
    end
  end

  shared_examples '件数情報が表示されていること' do |total: 0, from: 0, to: 0|
    it do
      info = @html.xpath("#{payment_list_xpath}/div/span[@id='page-info']/h4")
      is_asserted_by { info.present? }
      is_asserted_by { info.text.strip == "#{total}件中#{from}〜#{to}件を表示" }
    end
  end

  shared_examples 'タグ設定ボタンが表示されていること' do
    it do
      button_xpath = "#{payment_list_xpath}/div/button[@id='btn-assign-tag']" \
                     '/span[@class="glyphicon glyphicon-tag"]'
      is_asserted_by { @html.xpath(button_xpath).present? }
    end
  end

  shared_examples 'ページングが表示されていないこと' do
    it do
      paging = @html.xpath("#{payment_list_xpath}/span/nav[@class='pagination']")
      is_asserted_by { paging.blank? }
    end
  end

  shared_examples 'ページングが表示されていること' do
    paging_xpath = "#{payment_list_xpath}/span[@id='paginate']/nav[@class='pagination']"

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
                             '/a[@href="/management/payments?page=2"]')
      is_asserted_by { two_link.present? }
      is_asserted_by { two_link.text == '2' }
    end

    it '次のページへのボタンが表示されていること' do
      next_link = @html.xpath("#{paging_xpath}/li/span[@class='next']" \
                              '/a[@href="/management/payments?page=2"]')
      expected_text = I18n.t('views.management.common..pagination.next')
      is_asserted_by { next_link.present? }
      is_asserted_by { next_link.text == expected_text }
    end

    it '最後のページへのボタンが表示されていること' do
      last_link = @html.xpath("#{paging_xpath}/li/span[@class='last']/a")
      expected_text = I18n.t('views.management.common.pagination.last')
      is_asserted_by { last_link.present? }
      is_asserted_by { last_link.text == expected_text }
    end
  end

  shared_examples '表示件数が表示されていること' do
    it do
      per_page_xpath = "#{payment_list_xpath}/div/form[@id='per_page_form']"
      is_asserted_by { @html.xpath(per_page_xpath).present? }
    end
  end

  shared_examples 'テーブルのヘッダーが表示されていること' do
    table_header_xpath = "#{payment_list_xpath}//table[@id='payment_table']/thead/tr/th"

    %w[種類 日付 内容 カテゴリ タグ 金額].each.with_index(1) do |text, i|
      it "#{text}のヘッダーが表示されていること" do
        headers = @html.xpath(table_header_xpath)
        is_asserted_by { headers[i].present? }
        is_asserted_by { headers[i].text.strip == text }
      end
    end
  end

  shared_examples 'テーブルに表示されているデータが正しいこと' do |expected_size: 0|
    before(:each) do
      table_body_xpath = "#{payment_list_xpath}//table[@id='payment_table']/tbody/tr"
      @table_rows = @html.xpath(table_body_xpath)
    end

    it 'データの数が正しいこと' do
      is_asserted_by { @table_rows.size == expected_size }
    end

    it '背景色が正しいこと', if: expected_size > 0 do
      @table_rows.each do |tr|
        payment_type = tr.search('td.payment_type').first
        color_class = payment_type.attribute('class').value
        payment_type_class = payment_type.children.attribute('class').value

        if color_class.include?('success')
          is_asserted_by { payment_type_class.include?('glyphicon-plus-sign') }
        else
          is_asserted_by { payment_type_class.include?('glyphicon-minus-sign') }
        end
      end
    end
  end

  before(:all) do
    @payment = Payment.new
    @search_form = PaymentQuery.new
    Kaminari.config.default_per_page = per_page
  end

  before(:each) do
    render template: 'payments/index', layout: 'layouts/application'
    @html ||= Nokogiri.parse(response)
  end

  describe '収支情報が0件の場合' do
    include_context 'HTML初期化'
    include_context 'トランザクション作成'
    include_context '収支情報を登録する', 0

    it_behaves_like '画面共通テスト'
    it_behaves_like 'ページングが表示されていないこと'
    it_behaves_like '表示件数が表示されていること'
    it_behaves_like 'テーブルのヘッダーが表示されていること'
    it_behaves_like 'テーブルに表示されているデータが正しいこと'
  end

  describe "収支情報が#{per_page}件の場合" do
    expected = {size: per_page, total: per_page, from: 1, to: per_page}
    include_context 'HTML初期化'
    include_context 'トランザクション作成'
    include_context '収支情報を登録する', per_page

    it_behaves_like '画面共通テスト', expected: expected
    it_behaves_like 'ページングが表示されていないこと'
    it_behaves_like '表示件数が表示されていること'
    it_behaves_like 'テーブルのヘッダーが表示されていること'
    it_behaves_like 'テーブルに表示されているデータが正しいこと', expected_size: per_page
  end

  describe "収支情報が#{per_page + 1}件の場合" do
    expected = {size: per_page, total: per_page + 1, from: 1, to: per_page}
    include_context 'HTML初期化'
    include_context 'トランザクション作成'
    include_context '収支情報を登録する', per_page + 1

    it_behaves_like '画面共通テスト', expected: expected
    it_behaves_like 'ページングが表示されていること'
    it_behaves_like '表示件数が表示されていること'
    it_behaves_like 'テーブルのヘッダーが表示されていること'
    it_behaves_like 'テーブルに表示されているデータが正しいこと', expected_size: per_page
  end

  describe "収支情報が#{per_page + Kaminari.config.window * 2 + 1}件の場合" do
    total = per_page + Kaminari.config.window * 2 + 1
    expected = {size: per_page, total: total, from: 1, to: per_page}
    include_context 'HTML初期化'
    include_context 'トランザクション作成'
    include_context '収支情報を登録する', total

    it_behaves_like '画面共通テスト', expected: expected
    it_behaves_like 'ページングが表示されていること'
    it_behaves_like '表示件数が表示されていること'
    it_behaves_like 'テーブルのヘッダーが表示されていること'
    it_behaves_like 'テーブルに表示されているデータが正しいこと', expected_size: per_page
  end
end
