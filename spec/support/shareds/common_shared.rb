# coding: utf-8

shared_context 'トランザクション作成' do
  before(:all) { DatabaseCleaner.start }
  after(:all) { DatabaseCleaner.clean }
end

shared_examples 'レスポンスが正しいこと' do |status: 200, body: nil|
  it_behaves_like 'ステータスコードが正しいこと', status

  it 'レスポンスボディが正しいこと' do
    body ||= @body
    is_asserted_by { @response_body == body }
  end
end

shared_examples 'ステータスコードが正しいこと' do |status|
  it_is_asserted_by { @response_status == status }
end
