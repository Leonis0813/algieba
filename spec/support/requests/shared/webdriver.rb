# coding: utf-8

shared_context 'Webdriverを起動する' do
  before(:all) do
    @driver ||= Selenium::WebDriver.for :firefox
    @wait ||= Selenium::WebDriver::Wait.new(timeout: 30)
  end
end

shared_context 'Cookieをセットする' do
  before(:all) do
    @driver.get("#{base_url}/404_path")
    @driver.manage.add_cookie(name: 'algieba', value: cookie_value)
  end
end
