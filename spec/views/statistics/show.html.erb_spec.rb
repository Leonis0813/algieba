# coding: utf-8
require 'rails_helper'

describe 'statistics/show', :type => :view do
  html = nil

  before(:each) do
    render
    html ||= response
  end

  describe '<html><body>' do
    before(:all) { html = nil }

    describe '<div>' do
      it '<a>タグがあること' do
        expect(html).to have_selector('//div/a[href="/payments"]')
      end

      describe '<a>' do
        button_xpath = '//div/a/button[@class="btn btn-default btn-sm"]'

        it '<button>タグがあること' do
          expect(html).to have_selector(button_xpath)
        end

        it '<span>タグがあること' do
          expect(html).to have_selector("#{button_xpath}/span[@class='glyphicon glyphicon-edit']")
        end
      end
    end
  end
end
