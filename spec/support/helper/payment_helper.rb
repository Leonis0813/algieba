# coding: utf-8

module PaymentHelper
  def test_payment
    @test_payment ||= {
      income: {
        id: 1,
        payment_type: 'income',
        date: '1000-01-01',
        content: '機能テスト用データ1',
        categories: ['algieba'],
        price: 1000,
      },
      expense: {
        id: 2,
        payment_type: 'expense',
        date: '1000-01-05',
        content: '機能テスト用データ2',
        categories: ['algieba'],
        price: 100,
      },
    }
  end

  def response_keys
    @response_keys ||= %w[id payment_type date content categories price].sort
  end

  def delete_payments
    payments_path = "#{base_url}/api/payments"
    res = http_client.get(payments_path, {per_page: 100}, app_auth_header)
    JSON.parse(res.body)['payments'].each do |payment|
      http_client.delete("#{payments_path}/#{payment['id']}", nil, app_auth_header)
    end
  end

  module_function :test_payment, :response_keys
end
