# coding: utf-8
require 'rails_helper'

describe LoginController, :type => :controller do
  test_user_params = {:user_id => 'test_user_id', :password => 'test_user_pass'}

  shared_context 'ログインする' do |params|
    before(:all) { @res = client.post('/login', params) }
  end

  shared_examples 'Locationヘッダーが正しいこと' do |expected_url|
    it { expect(@res.headers['Location']).to eq expected_url }
  end

  describe '正常系' do
    before(:all) { User.create!(test_user_params) }
    after(:all) { User.find_by(test_user_params).destroy }

    context 'ユーザーが存在する場合' do
      include_context 'ログインする', test_user_params
      before(:all) do
        cookie = client.response.headers['Set-Cookie'].lines.find do |line|
          line.start_with?('algieba')
        end
        @user_cookie = cookie.split(';').first rescue nil
      end

      it_behaves_like 'ステータスコードが正しいこと', '302'
      it_behaves_like 'Locationヘッダーが正しいこと', 'http://160.16.66.112/'

      it 'cookieがセットされていること' do
        expect(@user_cookie).to be

        ticket = @user_cookie.match(/\Aalgieba=(?<ticket>.+)\z/)[:ticket]
        user_id, password = Base64.strict_decode64(ticket).split(':')
        expect({:user_id => user_id, :password => password}).to eq test_user_params
      end
    end
  end

  describe '異常系' do
    context 'ユーザーが存在しない場合' do
      include_context 'ログインする', test_user_params

      it_behaves_like 'ステータスコードが正しいこと', '302'
      it_behaves_like 'Locationヘッダーが正しいこと', 'http://160.16.66.112/login'

      it 'cookieがセットされていないこと' do
        expect(client.response.headers).not_to include('Set-Cookie')
      end
    end
  end
end
