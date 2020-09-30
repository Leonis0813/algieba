# coding: utf-8

require 'rails_helper'

describe StatisticsController, type: :controller do
  describe '#index' do
    describe '正常系' do
      before do
        get(:index)
        @response_status = response.status
      end

      it_behaves_like 'ステータスコードが正しいこと', 200
    end
  end
end
