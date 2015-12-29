# -*- coding: utf-8 -*-
require 'test_helper'

class AccountsControllerTest < ActionController::TestCase
  def setup
    @income = {
      'account_type' => accounts(:income).account_type,
      'date' => accounts(:income).date.strftime('%Y-%m-%d'),
      'content' => accounts(:income).content,
      'category' => accounts(:income).category,
      'price' => accounts(:income).price,
    }

    @expense = {
      'account_type' => accounts(:expense).account_type,
      'date' => accounts(:expense).date.strftime('%Y-%m-%d'),
      'content' => accounts(:expense).content,
      'category' => accounts(:expense).category,
      'price' => accounts(:expense).price,
    }
  end

  test 'should create account' do
    created_account = {
      :account_type => 'income',
      :date => '1000-01-01',
      :content => 'システムテスト用データ',
      :category => 'システムテスト',
      :price => 100,
    }

    post :create, {:accounts => created_account}

    assert_response :success

    parsed_body = JSON.parse(@response.body)
    created_account.each do |key, value|
      assert_equal value, parsed_body[key.to_s]
    end
  end

  test 'should get index with account_type' do
    get :read, {:account_type => 'income'}

    assert_response :success

    parsed_body = JSON.parse(@response.body)

    assert_equal 1, parsed_body.size
    @income.each do |key, value|
      assert_equal value, parsed_body.first[key]
    end
  end

  test 'should get index with date' do
    get :read, {:date => '1000-01-01'}

    assert_response :success

    parsed_body = JSON.parse(@response.body)

    assert_equal 2, parsed_body.size
    
    [@expense, @income].each_with_index do |account, i|
      account.each do |key, value|
        assert_equal value, parsed_body[i][key]
      end
    end
  end

  test 'should get index with content' do
    created_account = {
      :account_type => 'income',
      :date => '1000-01-01',
      :content => 'システムテスト用データ',
      :category => 'システムテスト',
      :price => 100,
    }
    Account.create!(created_account)

    get :read, {:content => 'システムテスト用データ'}

    assert_response :success

    parsed_body = JSON.parse(@response.body)

    assert_equal 1, parsed_body.size

    created_account.each do |key, value|
      assert_equal value, parsed_body.first[key.to_s]
    end

    Account.delete_all
  end

  test 'should get index with category' do
    created_account = {
      :account_type => 'income',
      :date => '1000-01-01',
      :content => 'システムテスト用データ',
      :category => 'システムテスト',
      :price => 100
    }
    Account.create!(created_account)

    get :read, {:category => 'システムテスト'}

    assert_response :success

    parsed_body = JSON.parse(@response.body)

    assert_equal 1, parsed_body.size

    created_account.each do |key, value|
      assert_equal value, parsed_body.first[key.to_s]
    end

    Account.delete_all
  end

  test 'should get index with price' do
    get :read, {:price => 100}

    assert_response :success

    parsed_body = JSON.parse(@response.body)

    assert_equal 2, parsed_body.size
    
    [@expense, @income].each_with_index do |account, i|
      account.each do |key, value|
        assert_equal value, parsed_body[i][key]
      end
    end
  end

  test 'should get index with account_type and category' do
    created_account = {
      :account_type => 'expense',
      :date => '1000-01-01',
      :content => 'システムテスト用データ',
      :category => 'システムテスト',
      :price => 100,
    }
    Account.create!(created_account)

    get :read, {:account_type => 'expense', :category => 'システムテスト'}

    assert_response :success

    parsed_body = JSON.parse(@response.body)

    assert_equal 1, parsed_body.size

    created_account.each do |key, value|
      assert_equal value, parsed_body.first[key.to_s]
    end

    Account.delete_all
  end

  test 'should get index without condition' do
    get :read

    assert_response :success

    parsed_body = JSON.parse(@response.body)

    assert_equal 2, parsed_body.size
    
    [@expense, @income].each_with_index do |account, i|
      account.each do |key, value|
        assert_equal value, parsed_body[i][key]
      end
    end

    Account.delete_all
  end

  test 'should update accounts(account_type)' do
    put :update, {
      :condition => {:account_type => 'expense'},
      :with => {:account_type => 'income'},
    }

    assert_response :success

    parsed_body = JSON.parse(@response.body)

    assert_equal 1, parsed_body.size
    
    @income.each do |key, value|
      assert_equal value, parsed_body.first[key]
    end
  end

  test 'should update accounts(date)' do
    put :update, {
      :condition => {:date => '1000-01-01'},
      :with => {:content => '更新後データ'},
    }

    assert_response :success

    parsed_body = JSON.parse(@response.body)

    assert_equal 2, parsed_body.size
    
    updated_value = {'content' => '更新後データ'}
    [@expense, @income].each_with_index do |account, i|
      account.merge(updated_value).each do |key, value|
        assert_equal value, parsed_body[i][key]
      end
    end
  end

  test 'should update accounts(content)' do
    created_account = {
      :account_type => 'income',
      :date => '1000-01-01',
      :content => 'システムテスト用データ',
      :category => 'システムテスト',
      :price => 100
    }
    Account.create!(created_account)

    put :update, {
      :condition => {:content => 'システムテスト用データ'},
      :with => {:price => 10000},
    }

    assert_response :success

    parsed_body = JSON.parse(@response.body)

    assert_equal 1, parsed_body.size
    
    updated_value = {:price => 10000}
    created_account.merge(updated_value).each do |key, value|
      assert_equal value, parsed_body.first[key.to_s]
    end

    Account.delete_all
  end

  test 'should update accounts(category)' do
    created_account = {
      :account_type => 'income',
      :date => '1000-01-01',
      :content => 'システムテスト用データ',
      :category => 'システムテスト',
      :price => 100
    }
    Account.create!(created_account)

    put :update, {
      :condition => {:category => 'システムテスト'},
      :with => {:account_type => 'expense'},
    }

    assert_response :success

    parsed_body = JSON.parse(@response.body)

    assert_equal 1, parsed_body.size
    
    updated_value = {:account_type => 'expense'}
    created_account.merge(updated_value).each do |key, value|
      assert_equal value, parsed_body.first[key.to_s]
    end

    Account.delete_all
  end

  test 'should update accounts(price)' do
    put :update, {
      :condition => {:price => 100},
      :with => {:category => '更新'},
    }

    assert_response :success

    parsed_body = JSON.parse(@response.body)

    assert_equal 2, parsed_body.size
    
    updated_value = {'category' => '更新'}
    [@expense, @income].each_with_index do |account, i|
      account.merge(updated_value).each do |key, value|
        assert_equal value, parsed_body[i][key]
      end
    end
  end

  test 'should update accounts(account_type, price)' do
    put :update, {
      :condition => {
        :account_type => 'expense',
        :price => 100,
      },
      :with => {:category => '更新'},
    }

    assert_response :success

    parsed_body = JSON.parse(@response.body)

    assert_equal 1, parsed_body.size
    
    updated_value = {'category' => '更新'}
    @expense.merge(updated_value).each do |key, value|
      assert_equal value, parsed_body.first[key]
    end
  end

  test 'should update accounts without condition' do
    put :update, {
      :with => {:price => 10},
    }

    assert_response :success

    parsed_body = JSON.parse(@response.body)

    assert_equal 2, parsed_body.size
    
    updated_value = {'price' => 10}
    [@expense, @income].each_with_index do |account, i|
      account.merge(updated_value).each do |key, value|
        assert_equal value, parsed_body[i][key]
      end
    end
  end

  test 'should update accounts with account_type' do
    put :update, {
      :condition => {:date => '1000-01-01'},
      :with => {:account_type => 'expense'},
    }

    assert_response :success

    parsed_body = JSON.parse(@response.body)

    assert_equal 2, parsed_body.size
    
    updated_value = {'account_type' => 'expense'}
    [@expense, @income].each_with_index do |account, i|
      account.merge(updated_value).each do |key, value|
        assert_equal value, parsed_body[i][key]
      end
    end
  end

  test 'should update accounts with date' do
    created_account = {
      :account_type => 'income',
      :date => '1000-01-01',
      :content => 'システムテスト用データ',
      :category => 'システムテスト',
      :price => 100
    }
    Account.create!(created_account)

    put :update, {
      :condition => {:category => 'システムテスト'},
      :with => {:date => '1000-01-02'},
    }

    assert_response :success

    parsed_body = JSON.parse(@response.body)

    assert_equal 1, parsed_body.size
    
    updated_value = {:date => '1000-01-02'}
    created_account.merge(updated_value).each do |key, value|
      assert_equal value, parsed_body.first[key.to_s]
    end

    Account.delete_all
  end

  test 'should update accounts with content' do
    put :update, {
      :condition => {:account_type => 'income'},
      :with => {:content => '更新後データ'},
    }

    assert_response :success

    parsed_body = JSON.parse(@response.body)

    assert_equal 1, parsed_body.size
    
    updated_value = {'content' => '更新後データ'}
    @income.merge(updated_value).each do |key, value|
      assert_equal value, parsed_body.first[key]
    end
  end

  test 'should update accounts with category' do
    put :update, {
      :condition => {:price => '100'},
      :with => {:category => '更新'},
    }

    assert_response :success

    parsed_body = JSON.parse(@response.body)

    assert_equal 2, parsed_body.size
    
    updated_value = {'category' => '更新'}
    [@expense, @income].each_with_index do |account, i|
      account.merge(updated_value).each do |key, value|
        assert_equal value, parsed_body[i][key]
      end
    end
  end

  test 'should update accounts with price' do
    put :update, {
      :condition => {
        :account_type => 'income',
        :date => '1000-01-01',
      },
      :with => {:price => 1000},
    }

    assert_response :success

    parsed_body = JSON.parse(@response.body)

    assert_equal 1, parsed_body.size
    
    updated_value = {'price' => 1000}
    @income.merge(updated_value).each do |key, value|
      assert_equal value, parsed_body.first[key]
    end
  end

  test 'should update accounts with multiple columns' do
    put :update, {
      :with => {
        :content => '更新後データ',
        :category => '更新',
      }
    }

    assert_response :success

    parsed_body = JSON.parse(@response.body)

    assert_equal 2, parsed_body.size
    
    updated_value = {
      'content' => '更新後データ',
      'category' => '更新',
    }
    [@expense, @income].each_with_index do |account, i|
      account.merge(updated_value).each do |key, value|
        assert_equal value, parsed_body[i][key]
      end
    end
  end

  test 'should delete account(account_type)' do
    delete :delete, {:account_type => 'expense'}
    assert_response :success
  end

  test 'should delete account(date)' do
    delete :delete, {:date => '1000-01-01'}
    assert_response :success
  end

  test 'should delete account(content)' do
    created_account = {
      :account_type => 'income',
      :date => '1000-01-01',
      :content => 'システムテスト用データ',
      :category => 'システムテスト',
      :price => 100
    }
    Account.create!(created_account)

    delete :delete, {:content => 'システムテスト用データ'}
    assert_response :success
  end

  test 'should delete account(category)' do
    created_account = {
      :account_type => 'income',
      :date => '1000-01-01',
      :content => 'システムテスト用データ',
      :category => 'システムテスト',
      :price => 100
    }
    Account.create!(created_account)

    delete :delete, {:category => 'システムテスト'}
    assert_response :success
  end

  test 'should delete account(price)' do
    delete :delete, {:price => 100}
    assert_response :success
  end

  test 'should delete account(account_type, price)' do
    delete :delete, {
      :account_type => 'expense',
      :price => 100,
    }
    assert_response :success
  end

  test 'should delete account without condition' do
    delete :delete
    assert_response :success
  end

  test 'should return settlements(yearly)' do
    get :settle, {:interval => 'yearly'}
    assert_equal({'1000' => 0}, JSON.parse(@response.body))
  end

  test 'should return settlements(monthly)' do
    get :settle, {:interval => 'monthly'}
    assert_equal({'1000-01' => 0}, JSON.parse(@response.body))
  end

  test 'should return settlements(daily)' do
    get :settle, {:interval => 'daily'}
    assert_equal({'1000-01-01' => 0}, JSON.parse(@response.body))
  end

  [:account_type, :date, :content, :category, :price].each do |delete_column|
    test "should send error code when create(#{delete_column})" do
      created_account = {
        :account_type => 'income',
        :date => '1000-01-01',
        :content => 'システムテスト用データ',
        :category => 'システムテスト',
        :price => 100,
      }.delete_if{|k, v| k == delete_column }

      post :create, {:accounts => created_account}

      assert_response :bad_request

      parsed_body = JSON.parse(@response.body)
      assert_equal 1, parsed_body.size
      assert_equal({'error_code' => "absent_param_#{delete_column}"}, parsed_body.first)
    end
  end

  test 'should send error code when create(date, price)' do
    created_account = {
      :account_type => 'income',
      :content => 'システムテスト用データ',
      :category => 'システムテスト',
    }

    post :create, {:accounts => created_account}

    assert_response :bad_request

    parsed_body = JSON.parse(@response.body)
    assert_equal 2, parsed_body.size
    [:date, :price].each_with_index do |key, i|
      assert_equal({'error_code' => "absent_param_#{key}"}, parsed_body[i])
    end
  end

  test 'should send error code when create(account_type, date, content, category, price)' do
    post :create, {:accounts => {}}

    assert_response :bad_request

    parsed_body = JSON.parse(@response.body)
    assert_equal 5, parsed_body.size
    [:account_type, :date, :content, :category, :price].each_with_index do |key, i|
      assert_equal({'error_code' => "absent_param_#{key}"}, parsed_body[i])
    end
  end

  test 'should send error code when create(accounts)' do
    post :create

    assert_response :bad_request

    parsed_body = JSON.parse(@response.body)
    assert_equal 1, parsed_body.size
    assert_equal({'error_code' => 'absent_param_accounts'}, parsed_body.first)
  end

  [
   {:account_type => 'invalid_type'},
   {:date => 'invalid_date'},
   {:price => 'invalid_price'},
  ].each do |invalid_param|
    key = invalid_param.keys.first
    test "should send error code when create with invalid #{key}" do
      created_account = {
        :account_type => 'expense',
        :date => '1000-01-01',
        :content => 'システムテスト用データ',
        :category => 'システムテスト',
        :price => 100,
      }.merge(invalid_param)

      post :create, {:accounts => created_account}

      assert_response :bad_request

      parsed_body = JSON.parse(@response.body)
      assert_equal 1, parsed_body.size
      assert_equal({'error_code' => "invalid_value_#{key}"}, parsed_body.first)
    end
  end

  test 'should send error code when create with invalid account_type and price' do
    created_account = {
      :account_type => 'invalid_type',
      :date => '1000-01-01',
      :content => 'システムテスト用データ',
      :category => 'システムテスト',
      :price => 'invalid_price',
    }

    post :create, {:accounts => created_account}

    assert_response :bad_request

    parsed_body = JSON.parse(@response.body)
    assert_equal 2, parsed_body.size
    [:account_type, :price].each_with_index do |key, i|
      assert_equal({'error_code' => "invalid_value_#{key}"}, parsed_body[i])
    end
  end

  [
   {:account_type => 'invalid_type'},
   {:date => 'invalid_date'},
   {:price => 'invalid_price'},
  ].each do |invalid_param|
    key = invalid_param.keys.first
    test "should send error code when index with invalid #{key}" do
      get :read, invalid_param

      assert_response :bad_request

      parsed_body = JSON.parse(@response.body)

      assert_equal 1, parsed_body.size
      assert_equal({'error_code' => "invalid_value_#{key}"}, parsed_body.first)
    end
  end

  test 'should send error code when update with invalid condition(account_type)' do
    put :update, {
      :condition => {:account_type => 'invalid_type'},
      :with => {:account_type => 'expense'},
    }

    assert_response :bad_request

    parsed_body = JSON.parse(@response.body)

    assert_equal 1, parsed_body.size
    assert_equal({'error_code' => 'invalid_value_account_type'}, parsed_body.first)
  end

  test 'should send error code when update with invalid condition(date)' do
    put :update, {
      :condition => {:date => '01-01-1000'},
      :with => {:price => 1000},
    }

    assert_response :bad_request

    parsed_body = JSON.parse(@response.body)

    assert_equal 1, parsed_body.size
    assert_equal({'error_code' => 'invalid_value_date'}, parsed_body.first)
  end

  test 'should send error code when update with invalid condition(price)' do
    put :update, {
      :condition => {:price => -1},
      :with => {:account_type => 'expense'},
    }

    assert_response :bad_request

    parsed_body = JSON.parse(@response.body)

    assert_equal 1, parsed_body.size
    assert_equal({'error_code' => 'invalid_value_price'}, parsed_body.first)
  end

  test 'should send error code when update with invalid value(account_type)' do
    put :update, {:with => {:account_type => 'invalid_type'}}

    assert_response :bad_request

    parsed_body = JSON.parse(@response.body)

    assert_equal 1, parsed_body.size
    assert_equal({'error_code' => 'invalid_value_account_type'}, parsed_body.first)
  end

  test 'should send error code when update with invalid value(date)' do
    put :update, {:with => {:date => 'invalid_date'}}

    assert_response :bad_request

    parsed_body = JSON.parse(@response.body)

    assert_equal 1, parsed_body.size
    assert_equal({'error_code' => 'invalid_value_date'}, parsed_body.first)
  end

  test 'should send error code when update with invalid value(price)' do
    put :update, {:with => {:price => 100.5}}

    assert_response :bad_request

    parsed_body = JSON.parse(@response.body)

    assert_equal 1, parsed_body.size
    assert_equal({'error_code' => 'invalid_value_price'}, parsed_body.first)
  end

  test 'should send error code when update without value' do
    put :update, {:with => {}}

    assert_response :bad_request

    parsed_body = JSON.parse(@response.body)
    assert_equal 1, parsed_body.size
    assert_equal({'error_code' => 'invalid_value_with'}, parsed_body.first)
  end

  test 'should send error code when update without with parameter' do
    put :update

    assert_response :bad_request

    parsed_body = JSON.parse(@response.body)
    assert_equal 1, parsed_body.size
    assert_equal({'error_code' => 'absent_param_with'}, parsed_body.first)
  end

  test 'should send error code when delete with invalid condition(accout_type)' do
    delete :delete, {:account_type => 'invalid_type'}

    assert_response :bad_request

    parsed_body = JSON.parse(@response.body)
    assert_equal 1, parsed_body.size
    assert_equal({'error_code' => 'invalid_value_account_type'}, parsed_body.first)
  end

  test 'should send error code when delete with invalid condition(date)' do
    delete :delete, {
      :date => 'invalid_date',
      :price => 100,
    }

    assert_response :bad_request

    parsed_body = JSON.parse(@response.body)
    assert_equal 1, parsed_body.size
    assert_equal({'error_code' => 'invalid_value_date'}, parsed_body.first)
  end

  test 'should send error code when delete with invalid condition(price)' do
    delete :delete, {
      :category => 'システムテスト',
      :price => 'invalid_price',
    }

    assert_response :bad_request

    parsed_body = JSON.parse(@response.body)
    assert_equal 1, parsed_body.size
    assert_equal({'error_code' => 'invalid_value_price'}, parsed_body.first)
  end

  test 'should send error code when settle with invalid interval' do
    get :settle, {:interval => 'invalid_interval'}

    assert_response :bad_request

    parsed_body = JSON.parse(@response.body)
    assert_equal 1, parsed_body.size
    assert_equal({'error_code' => 'invalid_value_interval'}, parsed_body.first)
  end

  test 'should send error code when settle without interval' do
    get :settle

    assert_response :bad_request

    parsed_body = JSON.parse(@response.body)
    assert_equal 1, parsed_body.size
    assert_equal({'error_code' => 'absent_param_interval'}, parsed_body.first)
  end
end
