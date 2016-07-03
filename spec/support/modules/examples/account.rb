# coding: utf-8

shared_examples_for 'Model: 取得した家計簿の数が正しいこと' do |size|
  it { expect(@accounts.size).to eq size }
end

shared_examples_for 'Model: 家計簿が正しく検索されていることを確認する' do |expected_accounts|
  it_behaves_like 'Model: 取得した家計簿の数が正しいこと', expected_accounts.size

  it '取得した家計簿が正しいこと' do
    actual_accounts = @accounts.to_a.map do |a|
      [a.account_type, a.date.strftime('%Y-%m-%d'), a.content, a.category, a.price]
    end
    expect(actual_accounts).to match_array expected_accounts.map {|a| a.except(:id).values }
  end
end

shared_examples_for 'Model: 収支が正しく計算されていることを確認する' do |settlement|
  it '計算結果が正しいこと' do
    expect(@settlement).to eq settlement
  end
end


shared_examples_for 'Controller: 家計簿が正しく登録されていることを確認する' do
  it_behaves_like 'ステータスコードが正しいこと', '201'

  it 'レスポンスの属性値が正しいこと' do
    actual_account = @pbody.slice(*@account_keys).symbolize_keys
    expect(actual_account).to eq @expected_account
  end
end

shared_examples_for 'Controller: 家計簿が正しく取得されていることを確認する' do
  it_behaves_like 'ステータスコードが正しいこと', '200'

  it 'レスポンスの属性値が正しいこと' do
    actual_account = @pbody.slice(*@account_keys).symbolize_keys
    expect(actual_account).to eq @expected_accounts
  end
end

shared_examples_for 'Controller: 家計簿が正しく更新されていることを確認する' do
  it_behaves_like 'ステータスコードが正しいこと', '200'

  it 'レスポンスの属性値が正しいこと' do
    actual_account = @pbody.slice(*@account_keys).symbolize_keys
    expect(actual_account).to eq @expected_account
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
