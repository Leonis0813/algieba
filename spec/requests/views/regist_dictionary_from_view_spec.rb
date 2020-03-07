# coding: utf-8

require 'rails_helper'

describe 'ブラウザから辞書を登録する', type: :request do
  alert_xpath = '//div[contains(@class, "bootbox-alert")]'
  default_input = {
    phrase: Time.zone.now.strftime('%F %T.%6N'),
    condition: 'include',
    categories: ['test'],
  }
  new_category_name = "new_category_#{Time.now.to_i}"

  shared_context '登録前の件数を確認する' do
    before(:all) do
      element = @wait.until do
        @driver.find_element(:xpath, '//div[@class="col-lg-8"]/div/h4')
      end
      @before_total_count = element.text.match(/(.*)件中/)[1].to_i
    end
  end

  shared_context '辞書情報を入力する' do |input = default_input|
    before(:all) do
      phrase_input = @wait.until { @driver.find_element(:id, 'phrase') }
      phrase_input.clear
      phrase_input.send_keys(input[:phrase])

      select_xpath = '//select[@id="condition"]'
      @wait.until { @driver.find_element(:xpath, select_xpath) }
      option_xpath = "#{select_xpath}/option[@value='#{input[:condition]}']"
      @wait.until do
        res = @driver.find_element(:xpath, option_xpath).click rescue false
        res.nil?
      end

      category_input = @wait.until { @driver.find_element(:id, 'dictionary_categories') }
      category_input.clear
      category_input.send_keys(input[:categories].join(','))
    end
  end

  shared_context '登録ボタンを押す' do
    before(:all) do
      @wait.until do
        res = @driver.find_element(:id, 'btn-create-dictionary').click rescue false
        res.nil?
      end
    end
  end

  shared_examples '登録に成功していること' do
    it '件数が増えていること' do
      element = @wait.until do
        @driver.find_element(:xpath, '//div[@class="col-lg-8"]/div/h4')
      end
      after_total_count = element.text.match(/(.*)件中/)[1].to_i

      is_asserted_by { after_total_count == @before_total_count + 1 }
    end
  end

  shared_examples '入力フォームが全て空であること' do
    %w[phrase dictionary_categories].each do |id|
      it_is_asserted_by { @driver.find_element(:id, id).text == '' }
    end
  end

  before(:all) { delete_payments }
  after(:all) { delete_payments }

  body = {
    payment_type: 'expense',
    date: '1000-01-01',
    content: 'システムテスト用データ',
    category: 'test',
    price: 100,
  }
  include_context 'POST /api/payments', body
  include_context 'Webdriverを起動する'
  include_context 'Cookieをセットする'

  before(:all) do
    @driver.get(base_url)
    @wait.until do
      res = @driver.find_element(:xpath, '//li/a[text()="辞書"]').click rescue false
      res.nil?
    end
  end

  describe '辞書情報を登録する' do
    include_context '登録前の件数を確認する'
    include_context '辞書情報を入力する'
    include_context '登録ボタンを押す'

    it_behaves_like '登録に成功していること'
    it_behaves_like '入力フォームが全て空であること'
  end

  describe '新しいカテゴリで辞書情報を登録する' do
    input = default_input.merge(
      condition: 'equal',
      categories: [new_category_name],
    )
    include_context '登録前の件数を確認する'
    include_context '辞書情報を入力する', input
    include_context '登録ボタンを押す'

    it_behaves_like '登録に成功していること'
    it_behaves_like '入力フォームが全て空であること'
  end

  describe 'カテゴリ一覧を確認する' do
    before(:all) do
      xpath = '//form[@id="new_dictionary"]//span[@class="category-list"]/button'
      @wait.until do
        res = @driver.find_element(:xpath, xpath).click rescue false
        res.nil?
      end
      @wait.until { @driver.find_element(:class, 'bootbox-prompt').displayed? }
    end

    after(:all) do
      xpath = '//div[contains(@class, "bootbox-prompt")]//button[text()="Cancel"]'
      cancel_button = @wait.until { @driver.find_element(:xpath, xpath) }
      cancel_button.click
      @wait.until { @driver.find_element(:xpath, xpath) rescue true }
    end

    it '新カテゴリが追加されていること' do
      is_asserted_by do
        @wait.until do
          @driver.find_element(:xpath, "//input[@value='#{new_category_name}']")
        end
      end
    end
  end
end
