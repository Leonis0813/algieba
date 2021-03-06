# coding: utf-8

module PaymentHelper
  def test_payment
    @test_payment ||= {
      income: {
        id: 1,
        payment_type: 'income',
        date: '1000-01-01',
        content: '機能テスト用データ1',
        categories: ['income'],
        tags: ['income'],
        price: 1000,
      },
      expense: {
        id: 2,
        payment_type: 'expense',
        date: '1000-01-05',
        content: '機能テスト用データ2',
        categories: ['expense'],
        tags: ['expense'],
        price: 100,
      },
    }
  end

  def response_keys
    @response_keys ||= %w[
      payment_id
      payment_type
      date
      content
      categories
      tags
      price
    ].sort
  end

  def delete_payments
    payments_path = "#{base_url}/api/payments"
    res = http_client.get(payments_path, {per_page: 100}, app_auth_header)
    JSON.parse(res.body)['payments'].each do |payment|
      url = "#{payments_path}/#{payment['payment_id']}"
      http_client.delete(url, nil, app_auth_header)
    end
  end

  module_function :test_payment, :response_keys
end
