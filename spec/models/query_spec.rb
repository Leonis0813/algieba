# coding: utf-8
require 'rails_helper'

describe Query, :type => :model do
  describe '#validates' do
    shared_context 'Queryオブジェクトを検証する' do |params|
      before(:all) do
        @query = Query.new(params)
        @query.validate
      end
    end

    shared_examples '検証結果が正しいこと' do |result|
      it { expect(@query.errors.empty?).to be result }
    end

    describe '正常系' do
      [
        {:account_type => 'income'},
        {:date_before => '1000-01-01'},
        {:date_before => '1000/01/01'},
        {:date_before => '01-01-1000'},
        {:date_before => '01/01/1000'},
        {:date_before => '10000101'},
        {:date_after => '1000-01-01'},
        {:date_after => '1000/01/01'},
        {:date_after => '01-01-1000'},
        {:date_after => '01/01/1000'},
        {:date_after => '10000101'},
        {:content_equal => 'content'},
        {:content_include => 'content'},
        {:category => 'category'},
        {:price_upper => 100},
        {:price_lower => 100},
        {:account_type => 'income', :date_before => '1000-01-01'},
        {:account_type => 'income', :date_after => '1000-01-01'},
        {:account_type => 'income', :content_equal => 'content'},
        {:account_type => 'income', :content_include => 'content'},
        {:account_type => 'income', :category => 'category'},
        {:account_type => 'income', :price_upper => 100},
        {:account_type => 'income', :price_lower => 100},
        {:date_before => '1000-01-01', :date_after => '1000-01-01'},
        {:date_before => '1000-01-01', :content_equal => 'content'},
        {:date_before => '1000-01-01', :content_include => 'content'},
        {:date_before => '1000-01-01', :category => 'category'},
        {:date_before => '1000-01-01', :price_upper => 100},
        {:date_before => '1000-01-01', :price_lower => 100},
        {:date_after => '1000-01-01', :content_equal => 'content'},
        {:date_after => '1000-01-01', :content_include => 'content'},
        {:date_after => '1000-01-01', :category => 'category'},
        {:date_after => '1000-01-01', :price_upper => 100},
        {:date_after => '1000-01-01', :price_lower => 100},
        {:content_equal => 'content', :category => 'category'},
        {:content_equal => 'content', :price_upper => 100},
        {:content_equal => 'content', :price_lower => 100},
        {:content_include => 'content', :category => 'category'},
        {:content_include => 'content', :price_upper => 100},
        {:content_include => 'content', :price_lower => 100},
        {:category => 'category', :price_upper => 100},
        {:category => 'category', :price_lower => 100},
        {:price_upper => 100, :price_lower => 100},
      ].each do |params|
        context "クエリに#{params.keys.join(',')}を指定した場合" do
          include_context 'Queryオブジェクトを検証する', params
          it_behaves_like '検証結果が正しいこと', true
        end
      end

    end

    describe '異常系' do
      [
        {:account_type => 'invalid_type'},
        {:date_before => 'invalid_date'},
        {:date_after => 'invalid_date'},
        {:price_upper => 'invalid_price'},
        {:price_upper => 1.0},
        {:price_upper => -1},
        {:price_lower => 'invalid_price'},
        {:price_lower => 1.0},
        {:price_lower => -1},
        {:account_type => 'invalid_type', :date_before => 'invalid_date'},
        {:account_type => 'invalid_type', :date_after => 'invalid_date'},
        {:account_type => 'invalid_type', :price_upper => 'invalid_price'},
        {:account_type => 'invalid_type', :price_upper => 1.0},
        {:account_type => 'invalid_type', :price_upper => -1},
        {:account_type => 'invalid_type', :price_lower => 'invalid_price'},
        {:account_type => 'invalid_type', :price_lower => 1.0},
        {:account_type => 'invalid_type', :price_lower => -1},
        {:date_before => 'invalid_date', :date_after => 'invalid_date'},
        {:date_before => 'invalid_date', :price_upper => 'invalid_price'},
        {:date_before => 'invalid_date', :price_upper => 1.0},
        {:date_before => 'invalid_date', :price_upper => -1},
        {:date_before => 'invalid_date', :price_lower => 'invalid_price'},
        {:date_before => 'invalid_date', :price_lower => 1.0},
        {:date_before => 'invalid_date', :price_lower => -1},
        {:date_after => 'invalid_date', :price_upper => 'invalid_price'},
        {:date_after => 'invalid_date', :price_upper => 1.0},
        {:date_after => 'invalid_date', :price_upper => -1},
        {:date_after => 'invalid_date', :price_lower => 'invalid_price'},
        {:date_after => 'invalid_date', :price_lower => 1.0},
        {:date_after => 'invalid_date', :price_lower => -1},
        {:price_upper => 'invalid_price', :price_lower => 'invalid_price'},
        {:price_upper => 'invalid_price', :price_lower => 1.0},
        {:price_upper => 'invalid_price', :price_lower => -1},
        {:price_upper => 1.0, :price_lower => 'invalid_price'},
        {:price_upper => 1.0, :price_lower => 1.0},
        {:price_upper => 1.0, :price_lower => -1},
        {:price_upper => -1, :price_lower => 'invalid_price'},
        {:price_upper => -1, :price_lower => 1.0},
        {:price_upper => -1, :price_lower => -1},
      ].each do |params|
        context "クエリに#{params.keys.join(',')}を指定した場合" do
          include_context 'Queryオブジェクトを検証する', params

          it_behaves_like '検証結果が正しいこと', false

          it 'エラーメッセージが正しいこと' do
            expect(@query.errors.messages).to eq params.map {|key, _| [key, ['invalid']] }.to_h
          end
        end
      end
    end
  end
end
