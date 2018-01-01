# coding: utf-8
require 'rails_helper'

describe Statistics::SettlementsController, :type => :controller do
  shared_context '収支を取得する' do |cookie = CommonHelper.user_cookie|
    before(:all) do
      client.header('Cookie', cookie ? "algieba=#{cookie}" : nil)
      @res = client.get('/statistics/settlements')
      @pbody = JSON.parse(@res.body) rescue nil
    end
  end

  shared_examples 'ログイン画面にリダイレクトされること' do
    it_is_asserted_by { @res.header['Location'] == "#{Capybara.app_host}/algieba/login" }
  end

  describe '正常系' do
    include_context '収支を取得する'
    it_behaves_like 'ステータスコードが正しいこと', '200'
  end

  describe '異常系' do
    context 'Cookieがない場合' do
      include_context '収支を取得する', nil
      it_behaves_like 'ステータスコードが正しいこと', '302'
      it_behaves_like 'ログイン画面にリダイレクトされること'
    end

    context 'Cookieが不正な場合' do
      include_context '収支を取得する', 'invalid'
      it_behaves_like 'ステータスコードが正しいこと', '302'
      it_behaves_like 'ログイン画面にリダイレクトされること'
    end
  end
end
