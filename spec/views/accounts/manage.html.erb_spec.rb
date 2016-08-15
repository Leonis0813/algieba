# coding: utf-8
require 'rails_helper'

describe "accounts/manage", :type => :view do
  before(:all) do
    @account = Account.new
    @all_accounts = Account.order(:date => :desc).page(1)
  end

  before(:each) do
    render
    @response ||= response
  end

  it '<form>タグがあること' do
    expect(@response).to have_selector('form[action="/accounts"][data-remote="true"][method="post"]')
  end

  %w[ date content category price ].each do |attribute|
    it "accounts[#{attribute}]を含む<input>タグがあること" do
      expect(@response).to have_selector("input[type='text'][name='accounts[#{attribute}]']", :text => '')
    end
  end

  %w[ income expense ].each do |account_type|
    it "value=#{account_type}を持つラジオボタンがあること" do
      expect(@response).to have_selector("input[type='radio'][value='#{account_type}']")
    end
  end

  it '支出が選択されていること' do
    expect(@response).to have_selector('input[type="radio"][value="expense"][checked="checked"]')
  end

  it '<table>タグがあること' do
    expect(@response).to have_selector('table[width="100%"]')
  end

  %w[ 種類 日付 内容 カテゴリ 金額 ].each do |header|
    it "<table>タグ内に<td>#{header}</td>があること" do
      expect(@response).to have_xpath("//table/tr/td[text()='#{header}']")
    end
  end

  context '家計簿が1件登録されている場合' do
    before(:all) do
      param = {
        :account_type => 'income',
        :date => '1000-01-01',
        :content => 'モジュールテスト用データ',
        :category => 'algieba',
        :price => 100,
      }
      Account.create!(param)
      @all_accounts = Account.order(:date => :desc).page(1)
    end

    after(:all) { Account.delete_all }

    it '家計簿が1件表示されていること' do
      expect(@response).to have_xpath('//table/tr/td', {:text => '収入', :count => 1})
    end

    it 'ページングボタンが表示されていないこと' do
      expect(@response).not_to have_xpath("//nav[@class='paginate']")
    end
  end

  context '家計簿が51件登録されている場合' do
    before(:all) do
      param = {
        :account_type => 'income',
        :date => '1000-01-01',
        :content => 'モジュールテスト用データ',
        :category => 'algieba',
        :price => 100,
      }
      51.times { Account.create!(param) }
      @all_accounts = Account.order(:date => :desc).page(1)
    end

    after(:all) { Account.delete_all }

    it '家計簿が50件表示されていること' do
      expect(@response).to have_xpath('//table/tr/td', {:text => '収入', :count => 50})
    end

    it 'ページングボタンが表示されていること' do
      expect(@response).to have_xpath("//nav[@class='pagination']")
    end
  end
end
