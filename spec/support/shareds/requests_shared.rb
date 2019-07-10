# coding: utf-8

shared_context 'POST /api/payments' do |body|
  before(:all) do
    header = {'Authorization' => app_auth_header}.merge(content_type_json)
    res = http_client.post("#{base_url}/api/payments", body.to_json, header)
    @response_status = res.status
    @response_body = JSON.parse(res.body) rescue res.body
  end
end

shared_context 'GET /api/payments' do |params = {}|
  before(:all) do
    header = {'Authorization' => app_auth_header}
    res = http_client.get("#{base_url}/api/payments", params, header)
    @response_status = res.status
    @response_body = JSON.parse(res.body) rescue res.body
  end
end

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
