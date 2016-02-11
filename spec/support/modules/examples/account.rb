# coding: utf-8

shared_examples_for 'Model: 実行結果が正しいこと' do |result|
  it { expect(@result).to be result }
end

shared_examples_for 'Model: 取得した家計簿の数が正しいこと' do |size|
  it { expect(@accounts.size).to eq size }
end

shared_examples_for 'Model: 家計簿が正しく取得されていることを確認する' do |expected|
  it_behaves_like 'Model: 実行結果が正しいこと', true
  it_behaves_like 'Model: 取得した家計簿の数が正しいこと', expected[:size]

  it '取得した家計簿が正しいこと' do
    actual_accounts = @accounts.to_a.map do |account|
      [account.account_type, account.date.strftime('%Y-%m-%d'), account.content, account.category, account.price]
    end
    expect(actual_accounts).to match_array expected[:accounts]
  end
end

shared_examples_for 'Model: 家計簿が正しく更新されていることを確認する' do |expected|
  it_behaves_like 'Model: 実行結果が正しいこと', true
  it_behaves_like 'Model: 取得した家計簿の数が正しいこと', expected[:size]

  it '取得した家計簿が正しいこと' do
    actual_accounts = @accounts.to_a.map do |account|
      [account.account_type, account.date.strftime('%Y-%m-%d'), account.content, account.category, account.price]
    end
    expect(actual_accounts).to match_array @expected_accounts
  end
end

shared_examples_for 'Model: 家計簿が正しく削除されていることを確認する' do
  it_behaves_like 'Model: 実行結果が正しいこと', true

  it '取得した家計簿が正しいこと' do
    expect(@accounts).to match_array []
  end
end

shared_examples_for 'Model: 収支が正しく計算されていることを確認する' do |settlement|
  it_behaves_like 'Model: 実行結果が正しいこと', true

  it '計算結果が正しいこと' do
    expect(@settlement).to eq settlement
  end
end

shared_examples_for 'Model: 不正なパラメーターの種類が正しいこと' do |invalid_columns|
  it { expect(@accounts).to eq invalid_columns }
end

shared_examples_for 'Model: 家計簿の取得に失敗していることを確認する' do |invalid_columns|
  it_behaves_like 'Model: 実行結果が正しいこと', false
  it_behaves_like 'Model: 不正なパラメーターの種類が正しいこと', invalid_columns
end

shared_examples_for 'Model: 家計簿の更新に失敗していることを確認する' do |invalid_columns|
  it_behaves_like 'Model: 実行結果が正しいこと', false
  it_behaves_like 'Model: 不正なパラメーターの種類が正しいこと', invalid_columns
end

shared_examples_for 'Model: 家計簿の削除に失敗していることを確認する' do |invalid_columns|
  it_behaves_like 'Model: 実行結果が正しいこと', false
  it_behaves_like 'Model: 不正なパラメーターの種類が正しいこと', invalid_columns
end

shared_examples_for 'Model: 収支の計算に失敗していることを確認する' do
  it '結果がnilであること' do
    expect(@result).to be nil
  end
end


shared_examples_for 'Controller: 家計簿が正しく登録されていることを確認する' do
  it_behaves_like 'ステータスコードが正しいこと', '201'

  it 'レスポンスの属性値が正しいこと' do
    expect(@pbody.slice(*@account_keys)).to eq @expected_account
  end
end

shared_examples_for 'Controller: 家計簿が正しく取得されていることを確認する' do
  it_behaves_like 'ステータスコードが正しいこと', '200'

  it 'レスポンスの属性値が正しいこと' do
    @actual_accounts = @pbody.map {|account| account.slice(*@account_keys) }
    expect(@actual_accounts).to eq @expected_accounts
  end
end

shared_examples_for 'Controller: 家計簿が正しく更新されていることを確認する' do
  it_behaves_like 'ステータスコードが正しいこと', '200'

  it 'レスポンスの属性値が正しいこと' do
    @actual_accounts = @pbody.map {|account| account.slice(*@account_keys) }
    expect(@actual_accounts).to eq @expected_accounts
  end
end

shared_examples_for 'Controller: 家計簿が正しく削除されていることを確認する' do
  it_behaves_like 'ステータスコードが正しいこと', '204'
end

shared_examples_for 'Controller: 収支が正しく計算されていることを確認する' do |expected_settlement|
  it_behaves_like 'ステータスコードが正しいこと', '200'

  it '計算結果が正しいこと' do
    expect(@pbody).to eq expected_settlement
  end
end
