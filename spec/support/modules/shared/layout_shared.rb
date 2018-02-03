# coding: utf-8
shared_examples 'ヘッダーが表示されていること' do
  it do
    base_xpath = '//div[@class="navbar navbar-default navbar-static-top"]/div[@class="container"]'
    title_xpath = [base_xpath, 'span[@class="navbar-brand"]'].join('/')
    expect(@html).to have_selector(title_xpath, :text => 'Payment Manager')

    ul_xpath = [
      base_xpath,
      'div[@class="navbar-collapse collapse navbar-responsive-collapse"]',
      'ul[@class="nav navbar-nav"]',
    ].join('/')
    [
      ['/payments', '管理画面'],
      ['/statistics', '統計画面'],
    ].each do |href, text|
      expect(@html).to have_selector("#{ul_xpath}/li/a[@href='#{href}']", :text => text)
    end
  end
end
