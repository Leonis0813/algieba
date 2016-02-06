# coding: utf-8

shared_examples_for 'ステータスコードが正しいこと' do |expected_code|
  it { expect(@res.code).to eq expected_code }
end

shared_examples_for 'レスポンスボディのキーが正しいこと' do |expected_keys|
  it { expect(@pbody.map {|hash| hash.keys }.uniq.flatten.sort).to eq expected_keys.sort }
end
