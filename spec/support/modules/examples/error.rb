# coding: utf-8

shared_examples '400エラーをチェックする' do |error_codes|
  it_behaves_like 'ステータスコードが正しいこと', 400

  it 'エラーコードが正しいこと' do
    expect(@pbody).to eq error_codes.map {|e| {'error_code' => e} }
  end
end
