# coding: utf-8

shared_context 'POST /api/payments' do |body|
  before(:all) do
    header = app_auth_header.merge(content_type_json)
    res = http_client.post("#{base_url}/api/payments", body.to_json, header)
    @response_status = res.status
    @response_body = JSON.parse(res.body) rescue res.body
  end
end

shared_context '収支情報を作成する' do |body|
  before(:all) do
    header = app_auth_header.merge(content_type_json)
    res = http_client.post("#{base_url}/api/payments", body.to_json, header)
    @response_status = res.status
    @response_body = JSON.parse(res.body) rescue res.body
  end
end

shared_context 'GET /api/payments' do |params = {}|
  before(:all) do
    res = http_client.get("#{base_url}/api/payments", params, app_auth_header)
    @response_status = res.status
    @response_body = JSON.parse(res.body) rescue res.body
  end
end

shared_context 'カテゴリ情報を検索する' do |query|
  before(:all) do
    res = http_client.get("#{base_url}/api/categories", query, app_auth_header)
    @response_status = res.status
    @response_body = JSON.parse(res.body) rescue res.body
  end
end

shared_context 'タグ情報を作成する' do |body|
  before(:all) do
    header = app_auth_header.merge(content_type_json)
    res = http_client.post("#{base_url}/api/tags", body.to_json, header)
    @response_status = res.status
    @response_body = JSON.parse(res.body) rescue res.body
  end
end

shared_context 'Webdriverを起動する' do
  before(:all) do
    @headless = Headless.new
    @headless.start
    @driver = Selenium::WebDriver.for :firefox
    @wait = Selenium::WebDriver::Wait.new(timeout: 30)
  end

  after(:all) do
    @driver.quit
    @headless.destroy
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

shared_examples '収支検索時のレスポンスが正しいこと' do
  it_is_asserted_by { @response_status == 200 }

  it 'レスポンスボディが正しいこと' do
    is_asserted_by { @response_body.keys.sort == %w[payments] }

    @response_body['payments'].each do |payment|
      is_asserted_by { payment.keys.sort == PaymentHelper.response_keys }

      payment['categories'].each do |category|
        is_asserted_by { category.keys.sort == CategoryHelper.response_keys }
      end
    end
  end
end

shared_examples '正しくエラーダイアログが表示されていること' do |message: ''|
  alert_xpath = '//div[contains(@class, "bootbox-alert")]'

  it 'タイトルが正しいこと' do
    xpath = "#{alert_xpath}//h4"
    is_asserted_by { @driver.find_element(:xpath, xpath).text == 'エラー' }
  end

  it 'メッセージが正しいこと' do
    xpath = "#{alert_xpath}//div[contains(@class, 'alert-danger')]"
    is_asserted_by { @driver.find_element(:xpath, xpath).text == message }
  end

  it 'OKボタンがあること' do
    xpath = "#{alert_xpath}//div[@class='modal-footer']/button"
    is_asserted_by { @driver.find_element(:xpath, xpath).text == 'OK' }
  end
end

shared_examples '表示されている件数が正しいこと' do |total, from, to|
  it_is_asserted_by do
    text = "#{total}件中#{from}〜#{to}件を表示"
    @wait.until do
      @driver.find_element(:xpath, '//div[@class="col-lg-8"]/div/span/h4').text == text
    end
  end
end

shared_examples '収支情報の数が正しいこと' do |expected_size|
  it_is_asserted_by do
    @driver.find_elements(:xpath, '//table/tbody/tr').size == expected_size
  end
end
