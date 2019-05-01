# coding: utf-8
shared_context 'POST /api/payments' do |payment|
  before(:all) do
    header = {'Authorization' => app_auth_header}.merge(content_type_json)
    @res = http_client.post("#{base_url}/api/payments", {payments: payment}.to_json, header)
    @pbody = JSON.parse(@res.body) rescue nil
  end
end

shared_context 'GET /api/payments' do |params = {}|
  before(:all) do
    header = {'Authorization' => app_auth_header}
    @res = http_client.get("#{base_url}/api/payments", params, header)
    @pbody = JSON.parse(@res.body) rescue nil
  end
end

shared_examples 'レスポンスボディのキーが正しいこと' do |payment_keys|
  it do
    Array.wrap(@pbody).each do |payment|
      is_asserted_by { payment.keys.sort == payment_keys.sort }
    end
  end
end

shared_examples '収支情報リソースのキーが正しいこと' do
  it do
    Array.wrap(@pbody).each do |payment|
      is_asserted_by { payment.keys.sort == PaymentHelper.response_keys.sort }
    end
  end
end

shared_examples 'カテゴリリソースのキーが正しいこと' do
  it do
    Array.wrap(@pbody).each do |resource|
      resource['categories'].each do |category|
        is_asserted_by { category.keys.sort == CategoryHelper.response_keys.sort }
      end
    end
  end
end

shared_examples '収支情報リソースの属性値が正しいこと' do |expected_payments|
  it do
    actual_payments = Array.wrap(@pbody).map {|payment| payment.slice(*payment_params).symbolize_keys }
    is_asserted_by { actual_payments == Array.wrap(expected_payments) }
  end
end

shared_examples 'カテゴリリソースの属性値が正しいこと' do |expected_categories|
  it do
    actual_categories = Array.wrap(@pbody).map do |body|
      body['categories'].map {|category| category['name'] }.sort
    end
    is_asserted_by { actual_categories == expected_categories }
  end
end
