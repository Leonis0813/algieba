# coding: utf-8

shared_context 'HTML初期化' do
  before(:all) { @html = nil }
end

shared_examples 'ヘッダーが表示されていること' do
  base_xpath = [
    '//body',
    'nav[@class="navbar navbar-inverse navbar-static-top"]',
    'div[@class="container"]',
  ].join('/')
  ul_xpath = [base_xpath, 'ul[@class="nav navbar-nav"]'].join('/')

  it do
    title = @html.xpath([base_xpath, 'a[@class="navbar-brand"]'].join('/'))
    is_asserted_by { title.present? }
    is_asserted_by { title.text == 'Payment Manager' }

    [
      ['/management/payments', '管理画面'],
      ['/statistics', '統計画面'],
    ].each do |href, text|
      link = @html.xpath("#{ul_xpath}/li/a[@href='#{href}']")
      is_asserted_by { link.present? }
      is_asserted_by { link.text == text }
    end
  end
end

shared_examples '管理画面のサブヘッダーが表示されていること' do
  ul_xpath = [
    '//div[@id="main-content"]',
    'nav[@class="navbar navbar-inverse navbar-static-top"]',
    'div[@class="container"]',
    'ul[@class="nav navbar-nav"]',
  ].join('/')

  [
    ['payments', '収支'],
    ['categories', 'カテゴリ'],
    ['dictionaries', '辞書'],
    ['tags', 'タグ'],
  ].each do |resource, title|
    it "#{title}情報の管理画面へのリンクが表示されていること" do
      link_xpath = [
        ul_xpath,
        "li[@id='link-management-#{resource}']",
        "a[@href='/management/#{resource}']",
      ].join('/')
      link = @html.xpath(link_xpath)
      is_asserted_by { link.present? }
      is_asserted_by { link.text == title }
    end
  end
end
