# coding: utf-8
module CommonHelper
  def http_client
    @http_client ||= HTTPClient.new
  end

  def base_url
    ENV['REMOTE_HOST']
  end

  def content_type_json
    {'Content-Type' => 'application/json'}
  end

  def cookie_value
    return @cookie_value if @cookie_value

    @cookie_value =
      Base64.strict_encode64("#{Settings.user_id}:#{Settings.user_password}")
  end

  def app_auth_header
    return @app_auth_header if @app_auth_header

    credential =
      Base64.strict_encode64("#{Settings.application_id}:#{Settings.application_key}")
    @app_auth_header = "Basic #{credential}"
  end

  def client
    @client ||= Capybara.page.driver
  end

  def generate_test_case(params)
    [].tap do |test_cases|
      params.keys.size.times do |i|
        params.keys.combination(i + 1).each do |some_keys|
          tmp_test_cases = [].tap do |tests|
            Array.wrap(params[some_keys.first]).each do |value|
              tests << {some_keys.first => value}
            end

            some_keys[1..-1].each do |key|
              tmp_tests = [].tap do |tmp_test|
                tests.each do |test|
                  Array.wrap(params[key]).each do |value|
                    tmp_test << test.merge(key => value)
                  end
                end
              end
              tests = tmp_tests
            end
            break tests
          end
          test_cases << tmp_test_cases
        end
      end
    end.flatten
  end

  module_function :client, :app_auth_header, :generate_test_case
end
