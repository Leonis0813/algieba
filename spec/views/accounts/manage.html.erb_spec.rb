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

  it '<tr id="append">があること' do
    expect(@response).to have_xpath('//table/tr[@id="append"]')
  end
end
