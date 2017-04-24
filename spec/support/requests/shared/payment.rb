# coding: utf-8
shared_context 'POST /payments' do |payment|
  before(:all) do
    header = {'Authorization' => app_auth_header}.merge(content_type_json)
    @res = http_client.post("#{base_url}/payments", {:payments => payment}.to_json, header)
    @pbody = JSON.parse(@res.body) rescue nil
  end
end

shared_context 'GET /payments' do |params = {}|
  before(:all) do
    header = {'Authorization' => app_auth_header}
    @res = http_client.get("#{base_url}/payments", params.to_json, header)
    @pbody = JSON.parse(@res.body) rescue nil
  end
end

shared_examples 'レスポンスボディのキーが正しいこと' do |payment_keys|
  it do
    Array.wrap(@pbody).each {|payment| expect(payment.keys.sort).to eq payment_keys.sort }
  end
end

shared_examples '収支情報リソースのキーが正しいこと' do
  it do
    Array.wrap(@pbody).each do |payment|
      expect(payment.keys.sort).to eq PaymentHelper.response_keys.sort
    end
  end
end

shared_examples 'カテゴリリソースのキーが正しいこと' do
  it do
    Array.wrap(@pbody).each do |resource|
      resource['categories'].each do |category|
        expect(category.keys.sort).to eq CategoryHelper.response_keys.sort
      end
    end
  end
end

shared_examples '収支情報リソースの属性値が正しいこと' do |expected_payments|
  it do
    actual_payments = Array.wrap(@pbody).map {|payment| payment.slice(*payment_params).symbolize_keys }
    expect(actual_payments).to eq Array.wrap(expected_payments)
  end
end

shared_examples 'カテゴリリソースの属性値が正しいこと' do |expected_categories|
  it do
    actual_categories = Array.wrap(@pbody).map do |body|
      body['categories'].map {|category| category['name'] }.sort
    end
    expect(actual_categories).to eq expected_categories
  end
end
