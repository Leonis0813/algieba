# coding: utf-8

require 'rails_helper'

describe StatisticsController, type: :controller do
  shared_context '収支を取得する' do
    before(:all) do
      @res = client.get('/statistics')
      @pbody = JSON.parse(@res.body) rescue nil
    end
  end

  describe '正常系' do
    include_context '収支を取得する'
    it_behaves_like 'ステータスコードが正しいこと', '200'
  end
end
