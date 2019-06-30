# coding: utf-8

shared_context 'Webdriverを起動する' do
  before(:all) do
    @driver ||= Selenium::WebDriver.for :firefox
    @wait ||= Selenium::WebDriver::Wait.new(timeout: 30)
  end
end

shared_context 'Cookieをセットする' do
  before(:all) do
    @driver.get("#{base_url.sub('/algieba', '')}/login.html")
    user_id = @wait.until { @driver.find_element(:id, 'user_id') }
    user_id.send_keys(Settings.user_id)
    password = @wait.until { @driver.find_element(:id, 'password') }
    password.send_keys(Settings.user_password)
    @driver.find_element(:xpath, '//button[@type="submit"]').click
    @wait.until { @driver.manage.cookie_named('LSID') }
  end
end
