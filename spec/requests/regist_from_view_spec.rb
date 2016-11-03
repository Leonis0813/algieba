# coding: utf-8
require 'rails_helper'

describe 'ブラウザから操作する', :type => :request, :js => true do
  default_inputs = {:date => '1000-01-01', :content => 'regist from view', :category => 'テスト', :price => 100}
  color = {'収入' => 'success', '支出' => 'danger'}

  shared_context '家計簿を登録する' do |inputs, account_type|
    before(:each) do
      inputs.each {|key, value| fill_in "accounts_#{key}", :with => value.to_s }
      choose "accounts_account_type_#{account_type}"
      find(:xpath, '//form/span/input[@value="登録"]').click
      sleep 1
    end
  end

  before(:all) do
    res = http_client.get("#{base_url}/accounts")
    size = JSON.parse(res.body).size
    account = default_inputs.merge(:account_type => 'income')
    (Kaminari.config.default_per_page - 1 - size).times do
      http_client.post("#{base_url}/accounts", {:accounts => account}.to_json, content_type_json)
    end
  end

  after(:all) do
    res = http_client.get("#{base_url}/accounts", :content_equal => 'regist from view')
    accounts = JSON.parse(res.body)
    accounts.each {|account| http_client.delete("#{base_url}/accounts/#{account['id']}") }
  end

  describe 'Webページを表示する' do
    before(:each) { page.driver.browser.authenticate('dev', '.dev') }
    before(:each) { visit '/' }

    %w[ date content category price ].each do |column|
      it "入力欄(id=accounts_#{column})が全て空白であること" do
        expect(page).to have_xpath("//form/span/input[@id='accounts_#{column}']", :text => '')
      end
    end

    it '入力欄の下に家計簿が表示されていること' do
      expect(page).to have_xpath('//table/tbody/tr', :count => Kaminari.config.default_per_page - 1)
    end

    it 'ページングボタンが表示されていないこと' do
      expect(page).not_to have_xpath('//nav[@class="pagination"]')
    end

    describe '家計簿を登録する' do
      include_context '家計簿を登録する', default_inputs.merge(:date => 'invalid_date'), 'income'

      it '家計簿の数が変わっていないこと' do
        expect(page).to have_xpath('//table/tbody/tr', :count => Kaminari.config.default_per_page - 1)
        expect(page).not_to have_xpath('//nav[@class="pagination"]')
      end

      describe '家計簿を登録する' do
        include_context '家計簿を登録する', default_inputs, 'expense'

        it '家計簿の数が1つ増えていること' do
          expect(page).to have_xpath('//table/tbody/tr', :count => Kaminari.config.default_per_page)
          expect(page).not_to have_xpath('//nav[@class="pagination"]')

          page.find_all(:xpath, '//table/tbody/tr').each do |account|
            type = account.find_all('td').first.text
            expect(account).to have_xpath("../tr[@class='#{color[type]}']")
          end
        end

        describe '家計簿を登録する' do
          include_context '家計簿を登録する', default_inputs, 'income'

          it '表示されている家計簿の数が変わっていないこと' do
            expect(page).to have_xpath('//table/tbody/tr', :count => Kaminari.config.default_per_page)
            expect(page).to have_xpath('//nav[@class="pagination"]')

            page.find_all(:xpath, '//table/tbody/tr').each do |account|
              type = account.find_all('td').first.text
              expect(account).to have_xpath("../tr[@class='#{color[type]}']")
            end
          end
        end
      end
    end
  end
end
