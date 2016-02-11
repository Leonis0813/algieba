# coding: utf-8
require 'rails_helper'

describe AccountsController, :type => :controller do
  income = {'account_type' => 'income', 'date' => '1000-01-01', 'content' => '機能テスト用データ', 'category' => '機能テスト', 'price' => 100}
  expense = {'account_type' => 'expense', 'date' => '1000-01-01', 'content' => '機能テスト用データ', 'category' => '機能テスト', 'price' => 100}
  account_keys = %w[account_type date content category price]

  include_context 'Controller: 共通設定'

  context '正常系' do
    context 'create' do
      before(:all) do
        @res = @client.post('/accounts', {:accounts => income})
        @pbody = JSON.parse(@res.body)
        @actual_account = @pbody.slice(*account_keys)
      end
      after(:all) { @client.delete('/accounts') }

      it_behaves_like 'Controller: 家計簿が正しく登録されていることを確認する', income
    end

    context 'read' do
      [
        ['種類を指定する場合', {:account_type => 'income'}, [income]],
        ['日付を指定する場合', {:date => '1000-01-01'}, [income, expense]],
        ['内容を指定する場合', {:content => '機能テスト用データ'}, [income, expense]],
        ['カテゴリを指定する場合', {:category => '機能テスト'}, [income, expense]],
        ['金額を指定する場合', {:price => 100}, [income, expense]],
        ['種類とカテゴリを指定する場合', {:account_type => 'income', :category => '機能テスト'}, [income]],
        ['条件を指定しない場合', {}, [income, expense]],
      ].each do |description, condition, expected_accounts|
        context description do
          before(:all) do
            [income, expense].each {|account| @client.post('/accounts', {:accounts => account}) }
            @res = @client.get('/accounts', condition)
            @pbody = JSON.parse(@res.body)
            @actual_accounts = @pbody.map {|account| account.slice(*account_keys) }
          end
          after(:all) { @client.delete('/accounts') }

          it_behaves_like 'Controller: 家計簿が正しく取得されていることを確認する', expected_accounts
        end
      end
    end

    context 'update' do
      [
        ['種類を指定して種類を更新する場合', {'account_type' => 'expense'}, {'account_type' => 'income'}, [expense]],
        ['日付を指定して内容を更新する場合', {'date' => '1000-01-01'}, {'content' => '更新後データ'}, [income, expense]],
        ['内容を指定して金額を更新する場合', {'content' => '機能テスト用データ'}, {'price' => 10000}, [income, expense]],
        ['カテゴリを指定して種類を更新する場合', {'category' => '機能テスト'}, {'account_type' => 'expense'}, [income, expense]],
        ['金額を指定してカテゴリを更新する場合', {'price' => 100}, {'category' => '更新'}, [income, expense]],
        ['種類と金額を指定してカテゴリを更新する場合', {'account_type' => 'expense', 'price' => 100}, {'category' => '更新'}, [expense]],
        ['条件を指定せずに金額を更新する場合', nil, {'price' => 10}, [income, expense]],
        ['条件を指定せずに内容とカテゴリを更新する場合', nil, {'content' => '更新後データ', 'category' => '更新'}, [income, expense]],
      ].each do |description, condition, with, updated_accounts|
        context description do
          before(:all) do
            [income, expense].each {|account| @client.post('/accounts', {:accounts => account}) }
            @res = @client.put('/accounts', {:condition => condition, :with => with}.select {|key, value| value })
            @pbody = JSON.parse(@res.body)
            @actual_accounts = @pbody.map {|account| account.slice(*account_keys) }
            @expected_accounts = updated_accounts.map {|account| account.merge(with) }
          end
          after(:all) { @client.delete('/accounts') }

          it_behaves_like 'Controller: 家計簿が正しく更新されていることを確認する'
        end
      end
    end

    context 'delete' do
      [
        ['種類を指定する場合', {'account_type' => 'expense'}],
        ['日付を指定する場合', {'date' => '1000-01-01'}],
        ['内容を指定する場合', {'content' => '機能テスト用データ'}],
        ['カテゴリを指定する場合', {'category' => '機能テスト'}],
        ['金額を指定する場合', {'price' => 100}],
        ['種類と金額を指定してカテゴリを更新する場合', {'account_type' => 'expense', 'price' => 100}],
        ['条件を指定せずに金額を更新する場合', {}],
      ].each do |description, condition|
        context description do
          before(:all) do
            [income, expense].each {|account| @client.post('/accounts', {:accounts => account}) }
            @res = @client.delete('/accounts', condition)
          end
          after(:all) { @client.delete('/accounts') }

          it_behaves_like 'Controller: 家計簿が正しく削除されていることを確認する'
        end
      end
    end

    context 'settle' do
      [
        ['年次を指定する場合', 'yearly', {'1000' => 0}],
        ['月次を指定する場合', 'monthly', {'1000-01' => 0}],
        ['日次を指定する場合', 'daily', {'1000-01-01' => 0}],
      ].each do |description, interval, expected_settlement|
        context description do
          before(:all) do
            [income, expense].each {|account| @client.post('/accounts', {:accounts => account}) }
            @res = @client.get('/settlement', {:interval => interval})
            @pbody = JSON.parse(@res.body)
          end
          after(:all) { @client.delete('/accounts') }

          it_behaves_like 'Controller: 収支が正しく計算されていることを確認する', expected_settlement
        end
      end
    end
  end

  context '異常系' do
    context 'create' do
      [
        ['種類がない場合', ['account_type']],
        ['日付がない場合', ['date']],
        ['内容がない場合', ['content']],
        ['カテゴリがない場合', ['category']],
        ['金額がない場合', ['price']],
        ['日付と金額がない場合', ['date', 'price']],
      ].each do |description, deleted_keys|
        context description do
          before(:all) do
            selected_keys = account_keys - deleted_keys
            @res = @client.post('/accounts', {:accounts => income.slice(*selected_keys)})
            @pbody = JSON.parse(@res.body)
          end

          it_behaves_like '400エラーをチェックする', deleted_keys.map {|key| "absent_param_#{key}" }
        end
      end

      [{}, {:accounts => {}}].each do |params|
        context 'accounts パラメーターがない場合' do
          before(:all) do
            @res = @client.post('/accounts', params)
            @pbody = JSON.parse(@res.body)
          end

          it_behaves_like '400エラーをチェックする', ['absent_param_accounts']
        end
      end

      [
        ['不正な種類を指定する場合', {'account_type' => 'invalid_type'}],
        ['不正な日付を指定する場合', {'date' => 'invalid_date'}],
        ['不正な金額を指定する場合', {'price' => 'invalid_price'}],
        ['不正な種類と金額を指定する場合', {'account_type' => 'invalid_type', 'price' => 'invalid_price'}],
      ].each do |description, invalid_param|
        context description do
          before(:all) do
            @res = @client.post('/accounts', {:accounts => expense.merge(invalid_param)})
            @pbody = JSON.parse(@res.body)
          end

          it_behaves_like '400エラーをチェックする', invalid_param.keys.map {|key| "invalid_param_#{key}" }
        end
      end
    end

    context 'read' do
      [
        ['不正な種類を指定する場合', {'account_type' => 'invalid_type'}],
        ['不正な日付を指定する場合', {'date' => 'invalid_date'}],
        ['不正な金額を指定する場合', {'price' => 'invalid_price'}],
      ].each do |description, condition|
        context description do
          before(:all) do
            [income, expense].each {|account| @client.post('/accounts', {:accounts => account}) }
            @res = @client.get('/accounts', condition)
            @pbody = JSON.parse(@res.body)
          end
          after(:all) { @client.delete('/accounts') }

          it_behaves_like '400エラーをチェックする', condition.keys.map {|key| "invalid_param_#{key}" }
        end
      end
    end

    context 'update' do
      [
        ['不正な種類を指定する場合', {'account_type' => 'invalid_type'}, {'account_type' => 'expense'}],
        ['不正な日付を指定する場合', {'date' => '01-01-1000'}, {'price' => 1000}],
        ['不正な金額を指定する場合', {'price' => -1}, {'account_type' => 'expense'}],
        ['不正な種類で更新する場合', nil, {'account_type' => 'invalid_type'}],
        ['不正な日付で更新する場合', nil, {'date' => 'invalid_date'}],
        ['不正な金額で更新する場合', nil, {'price' => 100.5}],
      ].each do |description, condition, with|
        context description do
          before(:all) do
            [income, expense].each {|account| @client.post('/accounts', {:accounts => account}) }
            @res = @client.put('/accounts', {:condition => condition, :with => with}.select {|key, value| value })
            @pbody = JSON.parse(@res.body)
          end
          after(:all) { @client.delete('/accounts') }

          it_behaves_like '400エラーをチェックする', (condition || with).keys.map {|key| "invalid_param_#{key}" }
        end
      end

      context '更新後の値がない場合' do
        before(:all) do
          [income, expense].each {|account| @client.post('/accounts', {:accounts => account}) }
          @res = @client.put('/accounts', {:with => {}})
          @pbody = JSON.parse(@res.body)
        end
        after(:all) { @client.delete('/accounts') }

        it_behaves_like '400エラーをチェックする', ['absent_param_with']
      end

      context 'with パラメーターがない場合' do
        before(:all) do
          [income, expense].each {|account| @client.post('/accounts', {:accounts => account}) }
          @res = @client.put('/accounts')
          @pbody = JSON.parse(@res.body)
        end
        after(:all) { @client.delete('/accounts') }

        it_behaves_like '400エラーをチェックする', ['absent_param_with']
      end
    end

    context 'delete' do
      [
        ['不正な種類を指定する場合', {'account_type' => 'invalid_type'}, {}],
        ['不正な日付を指定する場合', {'date' => 'invalid_date'}, {'price' => 100}],
        ['不正な金額を指定する場合', {'price' => 'invalid_price'}, {'category' => '機能テスト'}],
      ].each do |description, invalid_condition, condition|
        context description do
          before(:all) do
            [income, expense].each {|account| @client.post('/accounts', {:accounts => account}) }
            @res = @client.delete('/accounts', condition.merge(invalid_condition))
            @pbody = JSON.parse(@res.body)
          end
          after(:all) { @client.delete('/accounts') }

          it_behaves_like '400エラーをチェックする', invalid_condition.keys.map {|key| "invalid_param_#{key}" }
        end
      end
    end

    context 'settle' do
      context '不正な期間を指定する場合' do
        before(:all) do
          [income, expense].each {|account| @client.post('/accounts', {:accounts => account}) }
          @res = @client.get('/settlement', {:interval => 'invalid_interval'})
          @pbody ||= JSON.parse(@res.body)
        end
        after(:all) { @client.delete('/accounts') }

        it_behaves_like '400エラーをチェックする', ['invalid_param_interval']
      end

      context 'interval パラメーターがない場合' do
        before(:all) do
          [income, expense].each {|account| @client.post('/accounts', {:accounts => account}) }
          @res = @client.get('/settlement')
          @pbody = JSON.parse(@res.body)
        end
        after(:all) { @client.delete('/accounts') }

        it_behaves_like '400エラーをチェックする', ['absent_param_interval']
      end
    end
  end
end
