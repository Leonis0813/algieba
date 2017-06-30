# coding: utf-8

shared_examples_for 'ステータスコードが正しいこと' do |expected_code|
  it_is_asserted_by { @res.status.to_s == expected_code }
end

shared_examples '400エラーをチェックする' do |error_codes|
  it_behaves_like 'ステータスコードが正しいこと', '400'

  it 'エラーコードが正しいこと' do
    is_asserted_by { @pbody.map {|e| e['error_code'] }.sort == error_codes.sort }
  end
end
