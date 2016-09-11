# coding: utf-8
require 'rails_helper'

describe AccountsController, :type => :controller do
  shared_context '収支を計算する' do |params = {}|
    before(:all) do
      @res = client.get('/settlement.json', params)
      @pbody = JSON.parse(@res.body) rescue nil
    end
  end

  include_context '事前準備: 家計簿を登録する'

  describe '正常系' do
    [
      ['yearly', {'1000' => 900}],
      ['monthly', {'1000-01' => 900}],
      ['daily', {'1000-01-01' => 1000, '1000-01-05' => -100}],
    ].each do |interval, expected_settlement|
      context "#{interval}を指定する場合" do
        include_context '収支を計算する', {:interval => interval}

        it_behaves_like 'ステータスコードが正しいこと', '200'

        it '計算結果が正しいこと' do
          expect(@pbody).to eq expected_settlement
        end
      end
    end
  end

  describe '異常系' do
    [[nil, 'absent'], ['invalid_interval', 'invalid']].each do |interval, message|
      context "#{interval || 'nil'}を指定する場合" do
        include_context '収支を計算する', {:interval => interval}
        it_behaves_like '400エラーをチェックする', ["#{message}_param_interval"]
      end
    end

    context 'interval パラメーターがない場合' do
      include_context '収支を計算する'
      it_behaves_like '400エラーをチェックする', ['absent_param_interval']
    end
  end
end
