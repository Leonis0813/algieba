# coding: utf-8

require 'rails_helper'

describe '収支管理画面のテスト', type: :request do
  now = Time.now.to_i
  new_phrase = "test at #{now}"
  new_category = "新カテゴリ_#{now}"
  tag_name = SecureRandom.hex(5)
  per_page = Kaminari.config.default_per_page
  default_inputs = {
    date: '1000-01-01',
    content: 'regist from view',
    categories: ['テスト'],
    price: 100,
  }

  shared_context '収支情報を入力する' do |inputs, payment_type|
    before(:all) do
      @wait.until { @driver.find_element(:id, 'payment_date').displayed? }
      inputs.except(:categories).each do |key, value|
        element = @driver.find_element(:id, "payment_#{key}")
        element.clear
        element.send_keys(value.to_s)
      end
      xpath = '//form[@id="new_payment"]//span[@class="category-list"]/button'
      @driver.find_element(:xpath, xpath).click

      inputs[:categories].each do |category|
        xpath = "//div[@class='modal-dialog']//input[@value='#{category}']"
        @wait.until do
          @driver.find_element(:xpath, xpath).selected? ||
            (@driver.find_element(:xpath, xpath).click || true rescue false)
        end
      end

      xpath = '//button[@data-bb-handler="confirm"]'
      @wait.until do
        res = @driver.find_element(:xpath, xpath).click rescue false
        res.nil? ? true : false
      end

      xpath = '//h4[text()="カテゴリを選択してください"]'
      @wait.until { (not @driver.find_element(:xpath, xpath).displayed?) rescue true }

      id = "payment_payment_type_#{payment_type}"
      @wait.until do
        res = @driver.find_element(:id, id).click rescue false
        res.nil? ? true : false
      end
    end
  end

  shared_context '登録ボタンを押す' do
    before(:all) do
      xpath = '//form[@id="new_payment"]/input[@value="登録"]'
      @wait.until do
        res = @driver.find_element(:xpath, xpath).click rescue false
        res.nil? ? true : false
      end
    end
  end

  shared_context '辞書登録をキャンセルする' do
    before(:all) do
      xpath = '//button[@data-bb-handler="cancel"]'
      @wait.until do
        res = @driver.find_element(:xpath, xpath).click rescue false
        res.nil? ? true : false
      end
    end
  end

  shared_examples '入力フォームが全て空であること' do
    %w[date content categories price].each do |column|
      it_is_asserted_by { @driver.find_element(:id, "payment_#{column}").text == '' }
    end
  end

  shared_examples '辞書を登録するダイアログが表示されていること' do |
    phrase: 'regist from view',
    category: nil
  |
    it do
      xpath = "//input[@id='dialog-phrase'][@value='#{phrase}']"
      is_asserted_by { @wait.until { @driver.find_element(:xpath, xpath) } }

      xpath = '//select[@id="dialog-condition"]/option[@selected][@value="equal"]'
      is_asserted_by { @wait.until { @driver.find_element(:xpath, xpath) } }

      xpath = "//input[@id='dialog-categories'][@value='#{category}'][@disabled]"
      is_asserted_by { @wait.until { @driver.find_element(:xpath, xpath) } }
    end
  end

  shared_examples 'フォームに値がセットされていること' do |attribute|
    it_is_asserted_by do
      xpath = "//input[@name='#{attribute[:name]}'][@value='#{attribute[:value]}']"
      @driver.find_element(:xpath, xpath)
    end
  end

  before(:all) do
    payment = default_inputs.merge(payment_type: 'income', categories: ['テスト'])

    header = app_auth_header.merge(content_type_json)
    per_page.times do
      body = payment.merge(price: rand(100)).to_json
      http_client.post("#{base_url}/api/payments", body, header)
    end
  end

  include_context 'タグ情報を作成する', {name: tag_name}

  after(:all) { delete_payments }

  include_context 'Webdriverを起動する'
  include_context 'Cookieをセットする'

  describe '管理画面を開く' do
    before(:all) { @driver.get(base_url) }

    it '日付でソートされていること' do
      element = @wait.until { @driver.find_element(:class, 'sorting_desc') }
      is_asserted_by { element.text.strip == '日付' }
    end
  end

  describe '収支を登録する' do
    describe '不正な収支情報を登録する' do
      inputs = default_inputs.merge(price: 'invalid_price')
      include_context '収支情報を入力する', inputs, 'income'
      include_context '登録ボタンを押す'
      before(:all) do
        @wait.until { @driver.find_element(:class, 'modal-body').displayed? }
      end

      after(:all) do
        @wait.until do
          res =
            @driver.find_element(:xpath, '//div/button[text()="OK"]').click rescue false
          res.nil?
        end
      end

      it_behaves_like '正しくエラーダイアログが表示されていること',
                      message: '金額 が不正です'
      it_behaves_like '収支情報の数が正しいこと', per_page
    end

    describe '収支情報を登録する' do
      before(:all) do
        @wait.until { @driver.find_element(:id, 'payment_price').enabled? rescue false }
        element = @driver.find_element(:id, 'payment_price')
        element.clear
        element.send_keys('100')
      end
      include_context '登録ボタンを押す'

      it_behaves_like '辞書を登録するダイアログが表示されていること', category: 'テスト'
    end

    describe '辞書登録をキャンセルする' do
      include_context '辞書登録をキャンセルする'

      it_behaves_like '表示されている件数が正しいこと', per_page + 1, 1, per_page
      it_behaves_like '収支情報の数が正しいこと', per_page
    end

    describe 'カレンダーを表示する' do
      before(:all) do
        @wait.until { @driver.find_element(:id, 'payment_date').displayed? }
        @driver.find_element(:id, 'payment_date').click
      end

      it 'カレンダーが表示されていること' do
        is_asserted_by do
          @driver.find_element(:class, 'bootstrap-datetimepicker-widget')
        end
      end
    end

    describe '新しいカテゴリで収支情報を登録する' do
      input = default_inputs.merge(content: new_phrase)
      include_context '収支情報を入力する', input, 'income'
      before(:all) do
        element = @driver.find_element(:id, 'payment_categories')
        element.clear
        element.send_keys(new_category)
        element = @driver.find_element(:id, 'payment_tags')
        element.clear
        element.send_keys('テスト')
      end
      include_context '登録ボタンを押す'

      it_behaves_like '辞書を登録するダイアログが表示されていること',
                      phrase: new_phrase,
                      category: new_category
    end

    describe '辞書を登録する' do
      before(:all) do
        xpath = '//button[@data-bb-handler="ok"]'
        @wait.until do
          res = @driver.find_element(:xpath, xpath).click rescue false
          res.nil? ? true : false
        end
      end

      it_behaves_like '表示されている件数が正しいこと', per_page + 2, 1, per_page
      it_behaves_like '収支情報の数が正しいこと', per_page
    end

    describe 'カテゴリ一覧を確認する' do
      before(:all) do
        @driver.find_element(:xpath, '//form//span[@class="category-list"]/button').click
        @wait.until { @driver.find_element(:class, 'bootbox-prompt').displayed? }
      end

      after(:all) do
        xpath = '//div[contains(@class, "bootbox-prompt")]//button[text()="Cancel"]'
        cancel_button = @wait.until { @driver.find_element(:xpath, xpath) }
        cancel_button.click
        @wait.until { @driver.find_element(:xpath, xpath) rescue true }
      end

      it "#{new_category}が追加されていること" do
        is_asserted_by do
          @driver.find_element(:xpath, "//input[@value='#{new_category}']")
        end
      end
    end

    describe '収支情報を削除する' do
      before(:all) do
        @wait.until { (not @driver.find_element(:class, 'modal-backdrop')) rescue true }
        @driver.find_element(:xpath, '//td[@class="delete"]/button').click
        @wait.until { @driver.find_element(:class, 'bootbox-confirm').displayed? }
      end

      it 'ダイアログのタイトルが正しいこと' do
        xpath = '//div[contains(@class, "bootbox-confirm")]//div[@class="bootbox-body"]'
        is_asserted_by do
          @driver.find_element(:xpath, xpath).text == '本当に削除しますか？'
        end
      end

      describe '削除を確定する' do
        before(:all) do
          xpath = '//div[@class="modal-footer"]/button[@class="btn btn-success"]'
          @driver.find_element(:xpath, xpath).click

          xpath = '//div[@class="bootbox modal fade bootbox-confirm in"]'
          @wait.until { @driver.find_element(:xpath, xpath) rescue true }
        end

        it_behaves_like '表示されている件数が正しいこと', per_page + 1, 1, per_page
        it_behaves_like '収支情報の数が正しいこと', per_page
      end
    end

    describe '2ページ目にアクセスする' do
      before(:all) do
        @wait.until do
          res = @driver.find_element(:xpath, '//span[@class="next"]').click rescue false
          res.nil? ? true : false
        end
        @wait.until { URI.parse(@driver.current_url).query == 'page=2' }
      end

      it_behaves_like '表示されている件数が正しいこと',
                      per_page + 1, per_page + 1, per_page + 1
      it_behaves_like '収支情報の数が正しいこと', 1
    end
  end

  describe '収支を検索する' do
    before(:all) { @driver.find_element(:xpath, '//a[@href="#search-form"]').click }

    describe '不正な金額を入力して検索する' do
      before(:all) do
        @driver.find_element(:name, 'price_upper').send_keys('invalid')
        @driver.find_element(:id, 'btn-payment-search').click
        @wait.until { @driver.find_element(:class, 'bootbox-alert').displayed? }
      end

      after(:all) do
        button = @wait.until do
          @driver.find_element(:xpath, '//div/button[text()="OK"]')
        end
        button.click
        @wait.until { @driver.find_element(:class, 'bootbox-alert') rescue true }
        @driver.find_element(:name, 'price_upper').clear
      end

      it_behaves_like '正しくエラーダイアログが表示されていること',
                      message: '金額 が不正です'
    end

    describe '10000円以下の収支情報を検索する' do
      before(:all) do
        @wait.until do
          res =
            @driver.find_element(:xpath, '//a[@href="#search-form"]').click rescue false
          res.nil? ? true : false
        end
        @driver.find_element(:name, 'price_lower').send_keys('10000')
        @driver.find_element(:id, 'btn-payment-search').click
        @wait.until { @driver.current_url.include?('price_lower=10000') }
      end

      it_behaves_like '表示されている件数が正しいこと', per_page + 1, 1, per_page
      it_behaves_like '収支情報の数が正しいこと', per_page
      it_behaves_like 'フォームに値がセットされていること',
                      name: 'price_lower', value: '10000'
    end

    describe '金額でソートする' do
      before(:all) { @driver.find_element(:id, 'header_price').click }

      it '金額でソートされていること' do
        is_asserted_by { @driver.find_element(:class, 'sorting_asc').text == '金額' }
      end

      it '収支情報がソートされていること' do
        prices = @driver.find_elements(:class, 'sorting_1').map(&:text).map(&:to_i)
        is_asserted_by { prices == prices.sort }
      end
    end

    describe '不正な表示件数を入力する' do
      before(:all) do
        @driver.find_element(:id, 'per_page').send_keys('invalid')
        @driver.find_element(:id, 'per_page').submit
        @wait.until { @driver.find_element(:class, 'bootbox-alert').displayed? }
      end

      after(:all) do
        button = @wait.until do
          @driver.find_element(:xpath, '//div/button[text()="OK"]')
        end
        button.click
        @wait.until { @driver.find_element(:class, 'bootbox-alert') rescue true }
      end

      it_behaves_like '正しくエラーダイアログが表示されていること',
                      message: '表示件数には数値を入力してください'

      it '表示件数が空文字になっていること' do
        is_asserted_by { @driver.find_element(:id, 'per_page').text.empty? }
      end
    end

    describe '表示件数を変更する' do
      before(:all) do
        @driver.find_element(:id, 'per_page').send_keys('20')
        @driver.find_element(:id, 'per_page').submit
        @wait.until { @driver.current_url.include?('per_page=20') }
      end

      it_behaves_like '表示されている件数が正しいこと', per_page + 1, 1, 20
      it_behaves_like '収支情報の数が正しいこと', 20
      it_behaves_like 'フォームに値がセットされていること',
                      name: 'price_lower', value: '10000'
      it_behaves_like 'フォームに値がセットされていること', name: 'per_page', value: '20'
    end

    describe 'タグを設定する' do
      before(:all) do
        @wait.until do
          res = @driver.find_element(:id, 'checkbox-all').click rescue false
          res.nil? ? true : false
        end

        @wait.until do
          res = @driver.find_element(:id, 'btn-assign-tag').click rescue false
          res.nil? ? true : false
        end

        xpath = '//form[@class="bootbox-form"]/select'
        @wait.until do
          res = @driver.find_element(:xpath, xpath).click rescue false
          res.nil? ? true : false
        end

        xpath += "/option[@value='#{tag_name}']"
        @wait.until do
          res = @driver.find_element(:xpath, xpath).click rescue false
          res.nil? ? true : false
        end

        xpath = '//button[@data-bb-handler="confirm"]'
        @wait.until do
          res = @driver.find_element(:xpath, xpath).click rescue false
          res.nil? ? true : false
        end
      end

      it 'タグが設定されていること' do
        @wait.until do
          tds = @driver.find_elements(:xpath, '//td[contains(@class, "tag")]')
          tds.all? {|td| td.attribute('title').include?(tag_name) } rescue false
        end
      end
    end
  end
end
