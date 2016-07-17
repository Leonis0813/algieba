# coding: utf-8

shared_examples_for 'Request: 家計簿が正しく登録されていることを確認する' do
  it_behaves_like 'ステータスコードが正しいこと', '201'

  %w[account_type date content category price].each do |key|
    it "レスポンスボディのキーに#{key}が含まれていること" do
      expect(@pbody.keys).to include key
    end
  end
end

shared_examples_for 'Request: 家計簿が正しく取得されていることを確認する' do |expected_account|
  it_behaves_like 'ステータスコードが正しいこと', '200'

  it '取得された家計簿が正しいこと' do
    actual_account = @pbody.slice(*@attributes).symbolize_keys
    expect(actual_account).to eq expected_account
  end
end

shared_examples_for 'Request: 家計簿が正しく更新されていることを確認する' do |expected_account|
  it_behaves_like 'ステータスコードが正しいこと', '200'

  it '更新された家計簿が正しいこと' do
    actual_account = @pbody.slice(*@attributes).symbolize_keys
    expect(actual_account).to eq expected_account
  end
end

shared_examples_for 'Request: 家計簿が正しく検索されていることを確認する' do |expected_accounts|
  it_behaves_like 'ステータスコードが正しいこと', '200'

  it '検索された家計簿が正しいこと' do
    actual_accounts = @pbody.map {|account| account.slice(*@attributes).symbolize_keys }
    expect(actual_accounts).to eq Array.wrap(expected_accounts)
  end
end

shared_examples_for 'Request: 家計簿が正しく削除されていることを確認する' do
  it_behaves_like 'ステータスコードが正しいこと', '204'
end

shared_examples_for 'Request: 収支が正しく計算されていることを確認する' do |expected_settlement|
  it_behaves_like 'ステータスコードが正しいこと', '200'

  it '計算結果が正しいこと' do
    expect(@pbody).to eq expected_settlement
  end
end
