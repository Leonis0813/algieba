# coding: utf-8
require 'rails_helper'

shared_context '家計簿を取得する' do |query = {}|
  before(:all) { @result, @accounts = Account.show(query) }
end

shared_context '家計簿を更新する' do |condition, with|
  before(:all) { @result, @accounts = Account.update({:condition => condition, :with => with}) }
end

shared_context '家計簿を削除する' do |condition|
  before(:all) { @result, @accounts = Account.destroy(condition) }
end

shared_context '収支を計算する' do |interval|
  before(:all) { @result, @settlement = Account.settle(interval) }
end

shared_examples '家計簿が正しく取得されていることを確認する' do |expected|
  it '結果がtrueであること' do
    expect(@result).to be true
  end

  it "取得した家計簿の数が#{expected[:size]}であること" do
    expect(@accounts.size).to eq expected[:size]
  end

  it '取得した家計簿が正しいこと' do
    actual_accounts = @accounts.to_a.map do |account|
      [account.account_type, account.date.strftime('%Y-%m-%d'), account.content, account.category, account.price]
    end
    expect(actual_accounts).to match_array expected[:accounts]
  end
end

shared_examples '家計簿が正しく更新されていることを確認する' do |expected|
  it '結果がtrueであること' do
    expect(@result).to be true
  end

  it "取得した家計簿の数が#{expected[:size]}であること" do
    expect(@accounts.size).to eq(expected[:size])
  end

  it '取得した家計簿が正しいこと' do
    actual_accounts = @accounts.to_a.map do |account|
      [account.account_type, account.date.strftime('%Y-%m-%d'), account.content, account.category, account.price]
    end
    expect(actual_accounts).to match_array @expected_accounts
  end
end

shared_examples '家計簿が正しく削除されていることを確認する' do
  it '結果がtrueであること' do
    expect(@result).to be true
  end

  it '取得した家計簿が正しいこと' do
    expect(@accounts).to match_array []
  end
end

shared_examples '収支が正しく計算されていることを確認する' do |settlement|
  it '結果がtrueであること' do
    expect(@result).to be true
  end

  it '計算結果が正しいこと' do
    expect(@settlement).to eq settlement
  end
end

shared_examples '結果と不正なパラメーターを確認する' do |invalid_columns|
  it '結果がfalseであること' do
    expect(@result).to be false
  end

  it '不正なパラメーターの種類が正しいこと' do
    expect(@accounts).to eq invalid_columns
  end
end

shared_examples '家計簿の取得に失敗していることを確認する' do |invalid_columns|
  it_behaves_like '結果と不正なパラメーターを確認する', invalid_columns
end

shared_examples '家計簿の更新に失敗していることを確認する' do |invalid_columns|
  it_behaves_like '結果と不正なパラメーターを確認する', invalid_columns
end

shared_examples '家計簿の削除に失敗していることを確認する' do |invalid_columns|
  it_behaves_like '結果と不正なパラメーターを確認する', invalid_columns
end

shared_examples '収支の計算に失敗していることを確認する' do
  it '結果がnilであること' do
    expect(@result).to be nil
  end
end

describe Account, :type => :model do
  income = {
    :account_type => 'income', :date => '1000-01-01', :content => 'テスト用データ', :category => 'テスト', :price => 100
  }
  expense = {
    :account_type => 'expense', :date => '1000-01-01', :content => 'テスト用データ', :category => 'テスト', :price => 100
  }

  context 'show' do
    before(:all) { [income, expense].each {|account| Account.create(account) } }
    after(:all) { Account.delete_all }

    context '正常系' do
      [
        ['家計簿の種類を指定する', {:account_type => 'income'}, [income.values]],
        ['日付を指定する', {:date => '1000-01-01'}, [income.values, expense.values]],
        ['内容を指定する', {:content => 'テスト用データ'}, [income.values, expense.values]],
        ['カテゴリを指定する', {:category => 'テスト'}, [income.values, expense.values]],
        ['金額を指定する', {:price => 100}, [income.values, expense.values]],
        ['家計簿の種類とカテゴリを指定する', {:account_type => 'expense', :category => 'テスト'}, [expense.values]],
        ['内容と金額を指定する', {:content => 'テスト用データ', :price => 100}, [income.values, expense.values]],
        ['内容と金額を指定する', {:content => 'テスト用データ', :price => 1}, []],
        ['条件を指定しない', {}, [income.values, expense.values]],
      ].each do |description, query, expected_accounts|
        context description do
          include_context '家計簿を取得する', query

          it_behaves_like '家計簿が正しく取得されていることを確認する', :size => expected_accounts.size, :accounts => expected_accounts
        end
      end
    end

    context '異常系' do
      [
        ['不正な家計簿の種類を指定する', {:account_type => 'invalid_type'}, [:account_type]],
        ['不正な日付を指定する', {:date => '1000-00-00'}, [:date]],
        ['不正な金額を指定する', {:price => -100}, [:price]],
        ['不正な家計簿の種類と金額を指定する', {:account_type => 'invalid_type', :date => '1000-01-01', :price => 'invalid_price'}, [:account_type, :price]],
      ].each do |description, query, invalid_columns|
        context description do
          include_context '家計簿を取得する', query

          it_behaves_like '家計簿の取得に失敗していることを確認する', invalid_columns
        end
      end
    end
  end

  context 'update' do
    context '正常系' do
      [
        ['家計簿の種類を条件にして家計簿の種類を変更する', {:account_type => 'expense'}, {:account_type => 'income'}, [expense]],
        ['日付を条件にして日付を変更する', {:date => '1000-01-01'}, {:date => '1000-02-01'}, [income, expense]],
        ['内容を条件にして内容を変更する', {:content => 'テスト用データ'}, {:content => '更新後データ'}, [income, expense]],
        ['カテゴリを条件にしてカテゴリを変更する', {:category => 'テスト'}, {:category => '更新'}, [income, expense]],
        ['金額を条件にして金額を変更する', {:price => 100}, {:price => 1000}, [income, expense]],
        [
          '家計簿の種類と金額を条件にして家計簿の種類とカテゴリと金額を変更する',
          {:account_type => 'expense', :price => 100},
          {:account_type => 'income', :category => 'テスト', :price => 10000},
          [expense]
        ],
        [
          '家計簿の種類と金額を条件にして家計簿の種類とカテゴリと金額を変更する',
          {:account_type => 'expense', :price => 1},
          {:account_type => 'income', :category => 'テスト', :price => 10000},
          []
        ],
        ['条件を指定せずに家計簿の種類と金額を変更する', {}, {:account_type => 'income', :price => 100000}, [income, expense]],
      ].each do |description, condition, with, updated_accounts|
        context description do
          before(:all) do
            [income, expense].each {|account| Account.create(account) }
            @expected_accounts = updated_accounts.map {|account| account.merge(with).values }
          end
          after(:all) { Account.delete_all }
          include_context '家計簿を更新する', condition, with

          it_behaves_like '家計簿が正しく更新されていることを確認する', :size => updated_accounts.size
        end
      end
    end

    context '異常系' do
      [
        ['不正な家計簿の種類を指定する', {:account_type => 'invalid_type'}, {:account_type => 'income'}, [:account_type]],
        ['不正な日付を指定する', {:date => 'invalid_date'}, {:category => 'テスト'}, [:date]],
        ['不正な金額を指定する', {:price => 'invalid_price'}, {:price => 100}, [:price]],
        ['不正な金額を指定する', {:account_type => 'income', :price => -100}, {:account_type => 'expense'}, [:price]],
        ['不正な家計簿の種類を指定する', {:account_type => 'expense'}, {:account_type => 'invalid_type'}, [:account_type]],
        ['不正な日付を指定する', {:category => 'テスト'}, {:date => '1000-00-00'}, [:date]],
        ['不正な金額を指定する', {:price => 100}, {:price => -100}, [:price]],
        ['不正な家計簿の種類と日付を指定する', {:account_type => 'income', :category => 'テスト'}, {:account_type => 'invalid_type', :date => 'invalid_date'}, [:account_type, :date]],
        ['更新後の値を指定しない', {:account_type => 'expense', :category => 'テスト'}, {}, [:with]],
      ].each do |description, condition, with, invalid_columns|
        context description do
          before(:all) { [income, expense].each {|account| Account.create(account) } }
          after(:all) { Account.delete_all }
          include_context '家計簿を更新する', condition, with

          it_behaves_like '家計簿の更新に失敗していることを確認する', invalid_columns
        end
      end
    end
  end

  context 'destroy' do
    context '正常系' do
      [
        ['家計簿の種類を指定する', {:account_type => 'income'}],
        ['日付を指定する', {:date => '1000-01-01'}],
        ['内容を指定する', {:content => 'テスト用データ'}],
        ['カテゴリを指定する', {:category => 'テスト'}],
        ['金額を指定する', {:price => 100}],
        ['日付と金額を指定する', {:date => '1000-01-01', :price => 100}],
        ['日付と金額を指定する', {:date => '1000-01-01', :price => 1}],
        ['条件を指定しない', {}],
      ].each do |description, condition|
        context description do
          before(:all) { [income, expense].each {|account| Account.create(account) } }
          after(:all) { Account.delete_all }
          include_context '家計簿を削除する', condition

          it_behaves_like '家計簿が正しく削除されていることを確認する'
        end
      end
    end

    context '異常系' do
      [
        ['不正な家計簿の種類を指定する', {:account_type => 'invalid_type'}, [:account_type]],
        ['不正な日付を指定する', {:date => '1000-00-00'}, [:date]],
        ['不正な金額を指定する', {:price => -100}, [:price]],
        ['不正な家計簿の種類と日付を指定する', {:account_type => 'invalid_type', :date => 'invalid_date', :price => 100}, [:account_type, :date]],
      ].each do |description, condition, invalid_columns|
        context description do
          before(:all) { [income, expense].each {|account| Account.create(account) } }
          after(:all) { Account.delete_all }
          include_context '家計簿を削除する', condition

          it_behaves_like '家計簿の削除に失敗していることを確認する', invalid_columns
        end
      end
    end
  end

  context 'settle' do
    context '正常系' do
      before(:all) { [income, expense].each {|account| Account.create(account) } }
      after(:all) { Account.delete_all }

      [
        ['年次を指定する', 'yearly', {'1000' => 0}],
        ['月次を指定する', 'monthly', {'1000-01' => 0}],
        ['日次を指定する', 'daily', {'1000-01-01' => 0}],
      ].each do |description, interval, settlement|
        context description do
          include_context '収支を計算する', interval

          it_behaves_like '収支が正しく計算されていることを確認する', settlement
        end
      end
    end

    context '異常系' do
      [
        ['不正な期間を指定する', 'invalid_interval'],
        ['nilを指定する', nil],
      ].each do |description, interval|
        context description do
          include_context '収支を計算する', interval

          it_behaves_like '収支の計算に失敗していることを確認する'
        end
      end
    end
  end
end
