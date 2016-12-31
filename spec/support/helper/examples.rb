# coding: utf-8

shared_examples_for 'ステータスコードが正しいこと' do |expected_code|
  it { expect(@res.status.to_s).to eq expected_code }
end

shared_examples '400エラーをチェックする' do |error_codes|
  it_behaves_like 'ステータスコードが正しいこと', '400'

  it 'エラーコードが正しいこと' do
    expect(@pbody).to match_array error_codes.map {|e| {'error_code' => e} }
  end
end
