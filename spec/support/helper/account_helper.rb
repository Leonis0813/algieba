# coding: utf-8
module AccountHelper
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

  def response_keys
    account_params + %w[ id created_at updated_at ]
  end

  module_function :test_account, :account_params, :response_keys
end
