# coding: utf-8

shared_context 'HTML初期化' do
  before(:all) { @html = nil }
end

shared_examples 'ヘッダーが表示されていること' do
  it do
    base_xpath =
      '//div[@class="navbar navbar-default navbar-static-top"]/div[@class="container"]'
    title = @html.xpath([base_xpath, 'span[@class="navbar-brand"]'].join('/'))
    is_asserted_by { title.present? }
    is_asserted_by { title.text == 'Payment Manager' }

    ul_xpath = [
      base_xpath,
      'div[@class="navbar-collapse collapse navbar-responsive-collapse"]',
      'ul[@class="nav navbar-nav"]',
    ].join('/')

    [
      ['/payments', '管理画面'],
      ['/statistics', '統計画面'],
    ].each do |href, text|
      link = @html.xpath("#{ul_xpath}/li/a[@href='#{href}']")
      is_asserted_by { link.present? }
      is_asserted_by { link.text == text }
    end
  end
end
