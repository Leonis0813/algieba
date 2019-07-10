# coding: utf-8

shared_context 'トランザクション作成' do
  before(:all) { DatabaseCleaner.start }
  after(:all) { DatabaseCleaner.clean }
end

shared_examples 'レスポンスが正しいこと' do |status: 400, body: nil|
  it 'ステータスコードが正しいこと' do
    is_asserted_by { @response_status == status }
  end

  it 'レスポンスボディが正しいこと' do
    is_asserted_by { @response_body == body }
  end
end
