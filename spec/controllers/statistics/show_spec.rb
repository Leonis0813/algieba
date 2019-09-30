# coding: utf-8

require 'rails_helper'

describe StatisticsController, type: :controller do
  describe '正常系' do
    before(:all) do
      res = client.get('/statistics')
      @response_status = res.status
    end

    it_behaves_like 'ステータスコードが正しいこと', 200
  end
end
