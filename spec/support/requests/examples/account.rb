# coding: utf-8

shared_examples_for 'Request: 家計簿が正しく登録されていることを確認する' do
  it_behaves_like 'ステータスコードが正しいこと', '201'

  %w[account_type date content category price].each do |key|
    it "レスポンスボディのキーに#{key}が含まれていること" do
      expect(@pbody.keys).to include key
    end
  end
end

shared_examples_for 'Request: 家計簿が正しく検索されていることを確認する' do
  it_behaves_like 'ステータスコードが正しいこと', '200'

  %w[account_type date content category price].each do |key|
    it "レスポンスボディのキーに#{key}が含まれていること" do
      @pbody.each {|account| expect(account.keys).to include key }
    end
  end
end

shared_examples_for 'Request: 家計簿が正しく更新されていることを確認する' do
  it_behaves_like 'ステータスコードが正しいこと', '200'

  %w[account_type date content category price].each do |key|
    it "レスポンスボディのキーに#{key}が含まれていること" do
      @pbody.each {|account| expect(account.keys).to include key }
    end
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
