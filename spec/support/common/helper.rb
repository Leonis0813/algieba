# coding: utf-8
module CommonHelper
  def http_client
    @http_client ||= HTTPClient.new
  end

  def base_url
    'http://160.16.66.112:3000'
  end

  def content_type_json
    {'Content-Type' => 'application/json'}
  end

  def client
    @client ||= Capybara.page.driver
  end

  def test_account
    @test_account ||= {
      :income => {
        :id => 1,
        :account_type => 'income',
        :date => '1000-01-01',
        :content => '機能テスト用データ1',
        :category => 'algieba',
        :price => 1000,
      },
      :expense => {
        :id => 2,
        :account_type => 'expense',
        :date => '1000-01-05',
        :content => '機能テスト用データ2',
        :category => 'algieba',
        :price => 100,
      }
    }
  end

  def account_params
    @account_params ||= %w[ account_type date content category price ]
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

  module_function :client, :test_account, :account_params, :generate_test_case
end
