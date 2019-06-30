# coding: utf-8

require 'rails_helper'

describe 'statistics/show', type: :view do
  before(:each) do
    render template: 'statistics/show', layout: 'layouts/application'
    @html = response
  end

  describe '<html><body>' do
    it_behaves_like 'ヘッダーが表示されていること'
  end
end
