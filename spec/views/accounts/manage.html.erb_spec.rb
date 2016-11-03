# coding: utf-8
require 'rails_helper'

describe "accounts/manage", :type => :view do
  html = nil
  per_page = 1
  param = {:account_type => 'income', :date => '1000-01-01', :content => 'モジュールテスト用データ', :category => 'algieba', :price => 100}

  shared_context 'HTML初期化' do
    before(:all) { html = nil }
  end

  shared_context '家計簿を登録する' do |num|
    before(:all) do
      num.times { Account.create!(param) }
      @accounts = Account.order(:date => :desc).page(1)
    end

    after(:all) { Account.delete_all }
  end

  shared_examples '表示されている家計簿の数が正しいこと' do |expected_size|
    it { expect(html).to have_xpath('//table/tbody/tr/td', {:text => I18n.t('views.account.income'), :count => expected_size}) }
  end

  shared_examples '家計簿の背景色が正しいこと' do
    it do
      matched_data = html.gsub("\n", '').match(/<tr class="(?<color>.*?)">\s*<td>(?<account_type>.*?)<\/td>/)
      case matched_data[:account_type]
      when I18n.t('views.account.income')
        expect(matched_data[:color]).to eq('success')
      when I18n.t('views.account.expense')
        expect(matched_data[:color]).to eq('danger')
      end
    end
  end

  shared_examples 'ページネーションが正しく表示されていること' do
    it 'ページングボタンが表示されていること' do
      expect(html).to have_xpath("//nav[@class='pagination']")
    end

    it '前のページへのボタンが表示されていないこと' do
      expect(html).not_to have_xpath("//nav/span[@class='prev']/a", :text => I18n.t('views.pagination.previous'))
    end

    it '1ページ目が表示されていること' do
      expect(html).to have_xpath("//nav/span[@class='page current']", :text => 1)
    end

    it '2ページ目が表示されていること' do
      expect(html).to have_xpath("//nav/span[@class='page']/a[@href='/?page=2']", :text => 2)
    end

    it '次のページへのボタンが表示されていること' do
      expect(html).to have_xpath("//nav/span[@class='next']/a[@href='/?page=2']", :text => I18n.t('views.pagination.next'))
    end
  end

  before(:all) do
    @account = Account.new
    @accounts = Account.order(:date => :desc).page(1)
    Kaminari.config.default_per_page = per_page
  end

  before(:each) do
    render
    html ||= response
  end

  describe '静的コンテンツのテスト' do
    include_context 'HTML初期化'

    it '<form>タグがあること' do
      expect(html).to have_selector('form[action="/accounts"][data-remote="true"][method="post"][class="form-inline"]')
    end

    %w[ date content category price ].each do |attribute|
      it "accounts[#{attribute}]を含む<input>タグがあること" do
        expect(html).to have_selector("//span[class='input-custom']/input[type='text'][name='accounts[#{attribute}]'][class='form-control']", :text => '')
      end
    end

    %w[ income expense ].each do |account_type|
      it "value=#{account_type}を持つラジオボタンがあること" do
        expect(html).to have_selector("//span[class='input-custom']/input[type='radio'][value='#{account_type}']")
      end
    end

    it '支出が選択されていること' do
      expect(html).to have_selector('input[type="radio"][value="expense"][checked="checked"]')
    end

    it '登録ボタンがあること' do
      expect(html).to have_selector('//form/span[class="input-custom"]/input[type="submit"][class="btn btn-primary"]')
    end

    it '<hr>タグがあること' do
      expect(html).to have_selector('hr')
    end

    it '<div>タグがあること' do
      expect(html).to have_selector('div[id="pagination"]')
    end

    it '<table>タグがあること' do
      expect(html).to have_selector('table[class="table table-hover table-custom"]')
    end

    %w[ 種類 日付 内容 カテゴリ 金額 ].each do |header|
      it "<table>タグ内に<th>#{header}</th>があること" do
        expect(html).to have_xpath('//table/thead/tr/th', :text => header)
      end
    end

    it "<table>タグ内に<tbody>があること" do
      expect(html).to have_selector('tbody[id="accounts"]')
    end
  end

  context '家計簿が1件登録されている場合' do
    include_context 'HTML初期化'
    include_context '家計簿を登録する', 1

    it_behaves_like '表示されている家計簿の数が正しいこと', 1
    it_behaves_like '家計簿の背景色が正しいこと'

    it 'ページングボタンが表示されていないこと' do
      expect(html).not_to have_xpath("//nav[@class='paginate']")
    end
  end

  context "家計簿が#{per_page + 1}件登録されている場合" do
    include_context 'HTML初期化'
    include_context '家計簿を登録する', per_page + 1

    it_behaves_like '表示されている家計簿の数が正しいこと', per_page
    it_behaves_like '家計簿の背景色が正しいこと'
    it_behaves_like 'ページネーションが正しく表示されていること'
  end

  context "家計簿が#{per_page + 9}件登録されている場合" do
    include_context 'HTML初期化'
    include_context '家計簿を登録する', per_page + 9

    it_behaves_like '表示されている家計簿の数が正しいこと', per_page
    it_behaves_like '家計簿の背景色が正しいこと'
    it_behaves_like 'ページネーションが正しく表示されていること'

    it 'リンクが省略されていること' do
      expect(html).to have_xpath("//nav/span[@class='page gap']", :text => I18n.t('views.pagination.truncate'))
    end
  end
end
