# coding: utf-8

shared_examples '400エラーをチェックする' do |error_codes|
  it 'ステータスコードが400であること' do
    expect(@res.code).to eq '400'
  end

  it 'エラーコードが正しいこと' do
    expect(@pbody).to eq error_codes
  end
end
