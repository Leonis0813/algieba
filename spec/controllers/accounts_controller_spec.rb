# coding: utf-8
require 'rails_helper'

describe AccountsController, :type => :controller do
  income = {'account_type' => 'income', 'date' => '1000-01-01', 'content' => '機能テスト用データ', 'category' => '機能テスト', 'price' => 100}
  expense = {'account_type' => 'expense', 'date' => '1000-01-01', 'content' => '機能テスト用データ', 'category' => '機能テスト', 'price' => 100}
  account_keys = %w[account_type date content category price]

  context 'create' do
    context '正常系' do
      res, pbody = nil, nil

      before(:each) do
        res ||= post :create, {:accounts => income}
        pbody ||= JSON.parse(res.body)
      end

      it 'ステータスコードが201であること' do
        expect(res.code).to eq '201'
      end

      it 'レスポンスボディの属性値が正しいこと' do
        expect(pbody.slice(*account_keys)).to eq income
      end
    end
  end

  context 'read' do
    context '正常系' do
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
          res, pbody = nil, nil

          before(:each) do
            [income, expense].each {|account| post :create, {:accounts => account} } unless res
            res ||= get :read, condition
            pbody ||= JSON.parse(res.body)
          end

          it 'ステータスコードが200であること' do
            expect(res.code).to eq '200'
          end

          it 'レスポンスボディの属性値が正しいこと' do
            actual_accounts = pbody.map {|account| account.slice(*account_keys) }
            expect(actual_accounts).to eq expected_accounts
          end
        end
      end
    end
  end

  context 'update' do
    context '正常系' do
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
          res, pbody = nil, nil

          before(:each) do
            [income, expense].each {|account| post :create, {:accounts => account} } unless res
            res ||= put :update, {:condition => condition, :with => with}.select {|key, value| value }
            pbody ||= JSON.parse(res.body)
          end

          it 'ステータスコードが200であること' do
            expect(res.code).to eq '200'
          end

          it 'レスポンスボディの属性値が正しいこと' do
            actual_accounts = pbody.map {|account| account.slice(*account_keys) }
            expected_accounts = updated_accounts.map {|account| account.merge(with) }
            expect(actual_accounts).to eq expected_accounts
          end
        end
      end
    end
  end

  context 'delete' do
    context '正常系' do
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
          res = nil

          before(:each) do
            [income, expense].each {|account| post :create, {:accounts => account} } unless res
            res ||= delete :delete, condition
          end

          it 'ステータスコードが204であること' do
            expect(res.code).to eq '204'
          end
        end
      end
    end
  end

  context 'settle' do
    context '正常系' do
      [
        ['年次を指定する場合', 'yearly', {'1000' => 0}],
        ['月次を指定する場合', 'monthly', {'1000-01' => 0}],
        ['日次を指定する場合', 'daily', {'1000-01-01' => 0}],
      ].each do |description, interval, expected_settlement|
        context description do
          res, pbody = nil, nil

          before(:each) do
            [income, expense].each {|account| post :create, {:accounts => account} } unless res
            res ||= get :settle, {:interval => interval}
            pbody ||= JSON.parse(res.body)
          end

          it 'ステータスコードが200であること' do
            expect(res.code).to eq '200'
          end

          it '計算結果が正しいこと' do
            expect(pbody).to eq expected_settlement
          end
        end
      end
    end
  end
end
