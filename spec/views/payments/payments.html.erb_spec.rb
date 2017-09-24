# coding: utf-8
require 'rails_helper'

describe "payments/payments", :type => :view do
  html = nil
  per_page = 1
  param = {:payment_type => 'income', :date => '1000-01-01', :content => 'モジュールテスト用データ', :category => 'algieba', :price => 100}

  before(:all) { Category.create(:name => param[:category]) }
  after(:all) { Category.destroy_all }

  shared_context 'HTML初期化' do
    before(:all) { html = nil }
  end

  shared_context '収支情報を登録する' do |num|
    before(:all) do
      num.times { Payment.create!(param.except(:category)) }
      @payments = Payment.order(:date => :desc).page(1)
    end

    after(:all) { Payment.destroy_all }
  end

  shared_examples '表示されている収支情報の数が正しいこと' do |expected_size|
    it { expect(html).to have_xpath('//table/tbody/tr/td', {:text => I18n.t('views.payment.income'), :count => expected_size}) }
  end

  shared_examples '削除ボタンが表示されていること' do
    it { expect(html).to have_xpath('//table/tbody/tr/td/button/span[@class="glyphicon glyphicon-trash"]') }
  end

  shared_examples '収支情報の背景色が正しいこと' do
    it do
      matched_data = html.gsub("\n", '').match(/<td\s*class='(?<color>.*?)'\s*>(?<payment_type>.*?)<\/td>/)
      case matched_data[:payment_type]
      when I18n.t('views.payment.income')
        is_asserted_by { matched_data[:color] == 'success' }
      when I18n.t('views.payment.expense')
        is_asserted_by { matched_data[:color] == 'danger' }
      end
    end
  end

  shared_examples 'ページネーションが正しく表示されていること' do
    nav_xpath = '//div[@class="row row-center"]/div/nav[@class="pagination"]'

    it 'ページングボタンが表示されていること' do
      expect(html).to have_selector(nav_xpath)
    end

    it '先頭のページへのボタンが表示されていないこと' do
      expect(html).not_to have_selector("#{nav_xpath}/li/span[@class='first']/a", :text => I18n.t('views.pagination.first'))
    end

    it '前のページへのボタンが表示されていないこと' do
      expect(html).not_to have_selector("#{nav_xpath}/li/span[@class='prev']/a", :text => I18n.t('views.pagination.previous'))
    end

    it '1ページ目が表示されていること' do
      expect(html).to have_selector("#{nav_xpath}/li/span[@class='page current']", :text => 1)
    end

    it '2ページ目が表示されていること' do
      expect(html).to have_selector("#{nav_xpath}/li/span[@class='page']/a[href='/?page=2']", :text => 2)
    end

    it '次のページへのボタンが表示されていること' do
      expect(html).to have_selector("#{nav_xpath}/li/span[@class='next']/a[href='/?page=2']", :text => I18n.t('views.pagination.next'))
    end

    it '最後のページへのボタンが表示されていること' do
      expect(html).to have_selector("#{nav_xpath}/li/span[@class='last']/a", :text => I18n.t('views.pagination.last'))
    end
  end

  before(:all) do
    @payment = Payment.new
    @payments = Payment.order(:date => :desc).page(1)
    Kaminari.config.default_per_page = per_page
  end

  before(:each) do
    render
    html ||= response
  end

  describe '<html><body>' do
    include_context 'HTML初期化'

    describe '<form>' do
      form_xpath = '//form[action="/payments"][data-remote="true"][method="post"][@class="form-inline"]'

      it '<form>タグがあること' do
        expect(html).to have_selector(form_xpath)
      end

      describe '<span>' do
        span_xpath = "#{form_xpath}/span[@class='input-custom']"

        %w[ date content categories price ].each do |attribute|
          it "payments_#{attribute}を含む<label>タグがあること" do
            expect(html).to have_selector("#{span_xpath}/label[for='payments_#{attribute}']", :text => I18n.t("views.payment.#{attribute}") + '：')
          end

          it "payments[#{attribute}]を含む<input>タグがあること", :unless => %w[ date categories ].include?(attribute) do
            xpath = "#{span_xpath}/input[type='text'][name='payments[#{attribute}]'][@class='form-control'][required='required']"
            expect(html).to have_selector(xpath, :text => '')
          end
        end

        it 'id=date-formを含む<span>タグがあること' do
          expect(html).to have_selector("#{form_xpath}/span[id='date-form']")
        end

        it 'payments[date]を含む<input>タグがあること' do
          xpath = "#{span_xpath}/input[type='text'][name='payments[date]'][@class='form-control datepicker'][required='required']"
          expect(html).to have_selector(xpath, :text => '')
        end

        it 'payments[category]を含む<input>タグがあること' do
          xpath = "#{span_xpath}/input[type='text'][name='payments[category]'][@class='form-control'][required='required']"
          expect(html).to have_selector(xpath, :text => '')
        end

        it 'カテゴリ選択ボタンがあること' do
          xpath = "#{span_xpath}/span[id='category-list']/button/span[@class='glyphicon glyphicon-list']"
          expect(html).to have_selector(xpath)
        end

        %w[ income expense ].each do |payment_type|
          it "value=#{payment_type}を持つラジオボタンがあること" do
            expect(html).to have_selector("#{span_xpath}/input[type='radio'][value='#{payment_type}']")
          end
        end

        it '支出が選択されていること' do
          expect(html).to have_selector("#{span_xpath}/input[type='radio'][value='expense'][checked='checked']")
        end

        %w[ submit reset ].each do |type|
          it "#{type}ボタンがあること" do
            expect(html).to have_selector("#{span_xpath}/input[type='#{type}'][@class='btn btn-primary']")
          end
        end
      end
    end

    describe '<div class="row row-center">' do
      row_xpath = '//div[@class="row row-center"]'

      it 'ページング情報を表示するブロックがあること' do
        expect(html).to have_selector(row_xpath)
      end

      it '件数を表示するブロックがあること' do
        expect(html).to have_selector("#{row_xpath}/div")
      end

      it 'リンクを表示するブロックがあること' do
        expect(html).to have_selector("#{row_xpath}/div")
      end
    end

    describe '<table>' do
      table_xpath = '//table[@class="table table-hover"]'

      it '<table>タグがあること' do
        expect(html).to have_selector(table_xpath)
      end

      describe '<thead>' do
        %w[ type date content categories price ].each do |attribute|
          header = I18n.t("views.payment.#{attribute}")

          it "<th>#{header}</th>があること" do
            expect(html).to have_selector("#{table_xpath}/thead/tr/th", :text => header)
          end
        end
      end

      describe '<tbody>' do
        it '<tbody>があること' do
          expect(html).to have_selector("#{table_xpath}/tbody")
        end
      end
    end
  end

  describe '動的コンテンツのテスト' do
    context "収支情報が#{per_page}件登録されている場合" do
      include_context 'HTML初期化'
      include_context '収支情報を登録する', per_page

      it_behaves_like '表示されている収支情報の数が正しいこと', per_page
      it_behaves_like '削除ボタンが表示されていること'
      it_behaves_like '収支情報の背景色が正しいこと'

      it 'ページングボタンが表示されていないこと' do
        expect(html).not_to have_selector("//nav[@class='pagination']")
      end
    end

    context "収支情報が#{per_page + 1}件登録されている場合" do
      include_context 'HTML初期化'
      include_context '収支情報を登録する', per_page + 1

      it_behaves_like '表示されている収支情報の数が正しいこと', per_page
      it_behaves_like '削除ボタンが表示されていること'
      it_behaves_like '収支情報の背景色が正しいこと'
      it_behaves_like 'ページネーションが正しく表示されていること'
    end

    context "収支情報が#{per_page + 9}件登録されている場合" do
      include_context 'HTML初期化'
      include_context '収支情報を登録する', per_page + 9

      it_behaves_like '表示されている収支情報の数が正しいこと', per_page
      it_behaves_like '削除ボタンが表示されていること'
      it_behaves_like '収支情報の背景色が正しいこと'
      it_behaves_like 'ページネーションが正しく表示されていること'

      it 'リンクが省略されていること' do
        expect(html).to have_selector("//nav/li/span[@class='page gap']", :text => I18n.t('views.pagination.truncate'))
      end
    end
  end
end