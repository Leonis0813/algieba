# coding: utf-8

module PaymentHelper
  def test_payment
    @test_payment ||= {
      income: {
        id: 1,
        payment_type: 'income',
        date: '1000-01-01',
        content: '機能テスト用データ1',
        category: 'algieba',
        price: 1000,
      },
      expense: {
        id: 2,
        payment_type: 'expense',
        date: '1000-01-05',
        content: '機能テスト用データ2',
        category: 'algieba',
        price: 100,
      },
    }
  end

  def payment_params
    @payment_params ||= %w[payment_type date content category price]
  end

  def response_keys
    @response_keys ||= %w[id payment_type date content categories price]
  end

  module_function :test_payment, :payment_params, :response_keys
end
