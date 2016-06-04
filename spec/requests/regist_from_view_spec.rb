# coding: utf-8
require 'rails_helper'

describe 'ブラウザから操作する', :type => :request, :js => true do
  shared_context '家計簿を登録する' do |inputs, account_type|
    before(:each) do
      inputs.each {|key, value| fill_in "accounts_#{key}", :with => value }
      choose "accounts_account_type_#{account_type}"
      find(:xpath, '//form/input[@value="登録"]').click
    end
  end

  default_inputs = {
    :date => '1000-01-01',
    :content => 'システムテスト用データ',
    :category => 'テスト',
    :price => '100',
  }

  describe 'Webページを表示する' do
    before(:each) { page.driver.browser.authenticate('dev', '.dev') }
    before(:each) { visit '/' }

    it '入力欄が全て空白であること' do
      %w[ date content category price ].each do |column|
        expect(page).to have_xpath("//form/input[@id='accounts_#{column}']", :text => '')
      end
    end

    describe '家計簿を登録する' do
      before(:each) { @current_row = page.all('table tr').count - 2 }
      include_context '家計簿を登録する', default_inputs.merge(:date => '1000/01/01'), 'income'

      it '家計簿の数が変わっていないこと' do
        expect(page.all('table tr').count - 2).to eq @current_row
      end

      describe '家計簿を登録する' do
        include_context '家計簿を登録する', default_inputs, 'income'
        before(:each) { sleep 1 }

        it '家計簿の数が1つ増えていること' do
          expect(page.all('table tr').count - 2).to eq @current_row + 1
        end
      end
    end
  end
end
