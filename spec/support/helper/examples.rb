# coding: utf-8

shared_examples '400エラーをチェックする' do |error_codes|
  it_behaves_like 'ステータスコードが正しいこと', '400'

  it 'エラーコードが正しいこと' do
    is_asserted_by { @pbody.map {|e| e['error_code'] }.sort == error_codes.sort }
  end
end
