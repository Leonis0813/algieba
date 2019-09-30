# coding: utf-8

require 'rails_helper'

describe 'statistics/index', type: :view do
  include_context 'HTML初期化'

  before(:each) do
    render template: 'statistics/index', layout: 'layouts/application'
    @html ||= Nokogiri.parse(response)
  end

  it_behaves_like 'ヘッダーが表示されていること'

  context 'タブが表示されていること' do
    tab_xpath = '//ul[@class="nav nav-tabs"]'

    it '期間別のタブが表示されていること' do
      period_tab = @html.xpath("#{tab_xpath}/li[@class='active']/a[@href='#period']")
      is_asserted_by { period_tab.present? }
      is_asserted_by { period_tab.text == '期間別' }
    end

    it 'カテゴリ別のタブが表示されていること' do
      category_tab = @html.xpath("#{tab_xpath}/li/a[@href='#category']")
      is_asserted_by { category_tab.present? }
      is_asserted_by { category_tab.text == 'カテゴリ別' }
    end
  end

  context 'コンテンツが表示されていること' do
    content_xpath = '//div[@class="tab-content"]'
    period_content_xpath = [
      content_xpath,
      'div[@id="period"][@class="tab-pane active"]',
      '/span[@class="graph"]',
    ].join('/')
    category_content_xpath = [
      content_xpath,
      'div[@id="category"][@class="tab-pane"]',
      'div[@class="rows"]',
      'div[@class="col-lg-6"]',
    ].join('/')

    it '月別グラフを表示する領域があること' do
      monthly_content = @html.xpath("#{period_content_xpath}/svg[@id='monthly']")
      is_asserted_by { monthly_content.present? }
    end

    it '日別グラフを表示する領域があること' do
      daily_content = @html.xpath("#{period_content_xpath}/svg[@id='daily']")
      is_asserted_by { daily_content.present? }
    end

    it '収入の割合を表示する領域があること' do
      titles = @html.xpath("#{category_content_xpath}/h4[@class='title-stat-category']")
      income_content = @html.xpath(
        "#{category_content_xpath}/span[@class='graph']/svg[@id='income']",
      )
      is_asserted_by { titles.first.text == '収入' }
      is_asserted_by { income_content.present? }
    end

    it '支出の割合を表示する領域があること' do
      titles = @html.xpath("#{category_content_xpath}/h4[@class='title-stat-category']")
      expense_content = @html.xpath(
        "#{category_content_xpath}/span[@class='graph']/svg[@id='expense']",
      )
      is_asserted_by { titles.last.text == '支出' }
      is_asserted_by { expense_content.present? }
    end
  end
end
