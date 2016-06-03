# coding: utf-8
require 'rails_helper'

describe 'ブラウザから操作する', :type => :request, :js => true do
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

      before(:each) do
        fill_in 'accounts_date', :with => '1000/01/01'
        fill_in 'accounts_content', :with => 'システムテスト用データ'
        fill_in 'accounts_category', :with => 'テスト'
        fill_in 'accounts_price', :with => '100'
        choose 'accounts_account_type_income'
        find(:xpath, '//form/input[@value="登録"]').click
      end

      it '家計簿の数が変わっていないこと' do
        expect(page.all('table tr').count - 2).to eq @current_row
      end

      describe '家計簿を登録する' do
        before(:each) do
          fill_in 'accounts_date', :with => '1000-01-01'
          fill_in 'accounts_content', :with => 'システムテスト用データ'
          fill_in 'accounts_category', :with => 'テスト'
          fill_in 'accounts_price', :with => '100'
          choose 'accounts_account_type_income'
          find(:xpath, '//form/input[@value="登録"]').click
          sleep 1
        end

        it '家計簿の数が1つ増えていること' do
          expect(page.all('table tr').count - 2).to eq @current_row + 1
        end
      end
    end
  end
end
