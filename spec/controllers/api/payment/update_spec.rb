# coding: utf-8

require 'rails_helper'

describe Api::PaymentsController, type: :controller do
  category_keys = CategoryHelper.response_keys

  shared_context '収支情報を更新する' do |payment_id: nil, body: {}|
    before(:all) do
      payment_id ||= @payment.payment_id
      res = client.put("/api/payments/#{payment_id}", body)
      @response_status = res.status
      @response_body = JSON.parse(res.body) rescue res.body
    end
  end

  describe '正常系' do
    valid_attribute = {
      payment_type: %w[income expense],
      date: %w[1000-01-02],
      content: %w[更新],
      categories: [%w[updated]],
      tags: [%w[updated]],
      # price: [1, 10] test after removing capybara
    }

    CommonHelper.generate_test_case(valid_attribute).each do |body|
      context "#{body.keys.join(',')}を更新する場合" do
        include_context 'トランザクション作成'
        before(:all) { @payment = create(:payment) }
        include_context '収支情報を更新する', body: body
        before(:all) do
          new_category = Category.find_by(name: 'updated')
          categories = Array.wrap(new_category || @payment.categories)
          categories.map! {|category| category.slice(*category_keys) }

          new_tag = Tag.find_by(name: 'updated')
          tags = Array.wrap(new_tag || @payment.tags)
          tags.map! {|tag| tag.slice(:tag_id, :name) }

          @body = @payment.slice(:payment_id, :payment_type, :content, :price).merge(
            date: @payment.date.strftime('%F'),
            categories: categories,
            tags: tags,
          ).deep_stringify_keys.merge(body.except(:categories, :tags).stringify_keys)
        end

        it_behaves_like 'レスポンスが正しいこと'
      end
    end

    context '何も更新しない場合' do
      include_context 'トランザクション作成'
      before(:all) { @payment = create(:payment) }
      include_context '収支情報を更新する'
      before(:all) do
        categories = @payment.categories.map do |category|
          category.slice(*category_keys)
        end
        tags = @payment.tags.map {|tag| tag.slice(:tag_id, :name) }

        @body = @payment.slice(:payment_id, :payment_type, :content, :price).merge(
          date: @payment.date.strftime('%F'),
          categories: categories,
          tags: tags,
          ).deep_stringify_keys
      end

      it_behaves_like 'レスポンスが正しいこと'
    end

    [
      ['カテゴリリソースが既に存在している場合', categories: %w[algieba]],
      ['複数のカテゴリを指定した場合', categories: %w[algieba other_category]],
    ].each do |description, body|
      context description do
        include_context 'トランザクション作成'
        before(:all) do
          attribute = {categories: [build(:category, name: 'algieba')]}
          @payment = create(:payment, attribute)
        end
        include_context '収支情報を更新する', body: body
        before(:all) do
          categories = body[:categories].map do |category_name|
            Category.find_by(name: category_name).slice(*category_keys)
          end
          tags = @payment.tags.map {|tag| tag.slice(:tag_id, :name) }

          @body = @payment.slice(:payment_id, :payment_type, :content, :price).merge(
            date: @payment.date.strftime('%F'),
            categories: categories,
            tags: tags,
          ).deep_stringify_keys
        end

        it_behaves_like 'レスポンスが正しいこと'
      end
    end
  end

  describe '異常系' do
    invalid_attribute = {
      payment_type: ['invalid', ['income'], {type: 'income'}],
      date: ['invalid', '1000-13-01', ['1000-01-01'], {date: '1000-01-01'}],
      content: [['test'], {content: 'test'}],
      price: [[0], {price: 0}],
    }

    CommonHelper.generate_test_case(invalid_attribute).each do |body|
      context "#{body.keys.join(',')}が不正な場合" do
        errors = body.keys.map do |key|
          {
            'error_code' => 'invalid_parameter',
            'parameter' => key.to_s,
            'resource' => 'payment',
          }
        end
        include_context 'トランザクション作成'
        before(:all) { @payment = create(:payment) }
        include_context '収支情報を更新する', body: body
        it_behaves_like 'レスポンスが正しいこと', status: 400, body: {'errors' => errors}
      end
    end

    context 'categoriesが不正な場合' do
      errors = [
        {
          'error_code' => 'invalid_parameter',
          'parameter' => 'categories',
          'resource' => 'payment',
        }
      ]
      include_context 'トランザクション作成'
      before(:all) { @payment = create(:payment) }
      include_context '収支情報を更新する', body: {categories: [{category: 'test'}]}
      it_behaves_like 'レスポンスが正しいこと', status: 400, body: {'errors' => errors}
    end

    context 'categoriesが同じ値が指定されている場合' do
      errors = [
        {
          'error_code' => 'duplicated_resource',
          'parameter' => 'name',
          'resource' => 'category',
        }
      ]
      include_context 'トランザクション作成'
      before(:all) { @payment = create(:payment) }
      include_context '収支情報を更新する', body: {categories: %w[test test]}
      it_behaves_like 'レスポンスが正しいこと', status: 400, body: {'errors' => errors}
    end

    context 'tagsが不正な場合' do
      errors = [
        {
          'error_code' => 'invalid_parameter',
          'parameter' => 'tags',
          'resource' => 'payment',
        }
      ]
      include_context 'トランザクション作成'
      before(:all) { @payment = create(:payment) }
      include_context '収支情報を更新する', body: {tags: [{tag: 'test'}]}
      it_behaves_like 'レスポンスが正しいこと', status: 400, body: {'errors' => errors}
    end

    context 'tagsに同じ値が指定されている場合' do
      errors = [
        {
          'error_code' => 'duplicated_resource',
          'parameter' => 'name',
          'resource' => 'tag',
        }
      ]
      include_context 'トランザクション作成'
      before(:all) { @payment = create(:payment) }
      include_context '収支情報を更新する', body: {tags: %w[test test]}
      it_behaves_like 'レスポンスが正しいこと', status: 400, body: {'errors' => errors}
    end

    context '存在しないidを指定した場合' do
      include_context '収支情報を更新する', payment_id: 'not_exist'
      it_behaves_like 'レスポンスが正しいこと', status: 404, body: ''
    end
  end
end
