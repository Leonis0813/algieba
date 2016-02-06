# coding: utf-8

shared_examples_for 'ステータスコードが正しいこと' do |expected_code|
  it { expect(@res.code.to_s).to eq expected_code }
end

shared_examples_for 'レスポンスボディのキーが正しいこと' do |expected_keys|
  it { expect(@pbody.map {|hash| hash.keys }.uniq.flatten.sort).to eq expected_keys.sort }
end


shared_examples '400エラーをチェックする' do |error_codes|
  it_behaves_like 'ステータスコードが正しいこと', '400'

  it 'エラーコードが正しいこと' do
    expect(@pbody).to eq error_codes.map {|e| {'error_code' => e} }
  end
end
