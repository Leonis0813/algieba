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
    @app_auth_header = {'Authorization' => "Basic #{credential}"}
  end

  def client
    @client ||= Capybara.page.driver
  end

  def generate_test_case(params)
    [].tap do |test_cases|
      params.each do |attribute_name, values|
        values.each do |value|
          test_cases << {attribute_name => value}
        end
      end

      if params.keys.size > 1
        test_cases << params.map {|key, values| [key, values.first] }.to_h
      end
    end
  end

  def generate_combinations(keys)
    [].tap do |combinations|
      keys.size.times do |i|
        combinations << keys.combination(i + 1).to_a
      end
    end.flatten(1)
  end

  module_function :client, :app_auth_header, :generate_test_case, :generate_combinations
end
