# coding: utf-8

require 'rails_helper'

describe Api::PaymentsController, type: :controller do
  render_views
  category_keys = CategoryHelper.response_keys
  tag_keys = TagHelper.response_keys

  describe '#update' do
    shared_context '収支情報を更新する' do |payment_id: nil, body: {}|
      before do
        payment_id ||= @payment.payment_id
        put(:update, params: {payment_id: payment_id}.merge(body), as: :json)
        @response_status = response.status
        @response_body = JSON.parse(response.body) rescue response.body
      end
    end

    shared_examples 'DBの収支情報が更新されていること' do |body|
      body.except(:date, :categories, :tags).each do |key, value|
        it "#{key}が#{value}に更新されていること" do
          is_asserted_by { @payment[key] == value }
        end
      end

      it "dateが#{body[:date]}に更新されていること", if: body[:date].present? do
        is_asserted_by { @payment.date == Date.parse(body[:date]) }
      end

      it 'カテゴリが更新されていること', if: body[:categories].present? do
        is_asserted_by do
          @payment.categories.pluck(:name).sort == body[:categories].sort
        end
      end

      it 'タグが更新されていること', if: body[:tags].present? do
        is_asserted_by do
          @payment.tags.pluck(:name).sort == body[:tags].sort
        end
      end
    end

    describe '正常系' do
      valid_attribute = {
        payment_type: %w[income expense],
        date: %w[1000-01-02],
        content: %w[更新],
        price: [1, 10],
        categories: [%w[updated]],
        tags: [%w[updated], []],
      }

      CommonHelper.generate_test_case(valid_attribute).each do |body|
        context "#{body.keys.join(',')}を更新する場合" do
          include_context 'トランザクション作成'
          before(:all) { @payment = create(:payment) }
          include_context '収支情報を更新する', body: body
          before do
            category_names = body[:categories] || @payment.categories.pluck(:name)
            categories = category_names.map do |category_name|
              Category.find_by(name: category_name)
            end

            tag_names = body[:tags] || @payment.tags.pluck(:name)
            tags = tag_names.map {|tag_name| Tag.find_by(name: tag_name) }

            @body = @payment.slice(:payment_id, :payment_type, :content, :price).merge(
              date: @payment.date.strftime('%F'),
              categories: categories.map {|category| category.slice(*category_keys) },
              tags: tags.map {|tag| tag.slice(*tag_keys) },
            ).deep_stringify_keys.merge(body.except(:categories, :tags).stringify_keys)
            @payment.reload
          end

          it_behaves_like 'レスポンスが正しいこと'
          it_behaves_like 'DBの収支情報が更新されていること', body
        end
      end

      context '何も更新しない場合' do
        include_context 'トランザクション作成'
        before(:all) { @payment = create(:payment) }
        include_context '収支情報を更新する'
        before do
          categories = @payment.categories.map do |category|
            category.slice(*category_keys)
          end

          @body = @payment.slice(:payment_id, :payment_type, :content, :price).merge(
            date: @payment.date.strftime('%F'),
            categories: categories,
            tags: @payment.tags.map {|tag| tag.slice(*tag_keys) },
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
          before do
            categories = body[:categories].map do |category_name|
              Category.find_by(name: category_name).slice(*category_keys)
            end

            @body = @payment.slice(:payment_id, :payment_type, :content, :price).merge(
              date: @payment.date.strftime('%F'),
              categories: categories,
              tags: @payment.tags.map {|tag| tag.slice(*tag_keys) },
            ).deep_stringify_keys
            @payment.reload
          end

          it_behaves_like 'レスポンスが正しいこと'
          it_behaves_like 'DBの収支情報が更新されていること', body
        end
      end

      [
        ['タグリソースが既に存在している場合', tags: %w[algieba]],
        ['複数のタグを指定した場合', tags: %w[algieba other_tag]],
      ].each do |description, body|
        context description do
          include_context 'トランザクション作成'
          before(:all) do
            attribute = {tags: [build(:tag, name: 'algieba')]}
            @payment = create(:payment, attribute)
          end
          include_context '収支情報を更新する', body: body
          before do
            categories = @payment.categories.map do |category|
              category.slice(*category_keys)
            end
            tags = body[:tags].map do |tag_name|
              Tag.find_by(name: tag_name).slice(*tag_keys)
            end

            @body = @payment.slice(:payment_id, :payment_type, :content, :price).merge(
              date: @payment.date.strftime('%F'),
              categories: categories,
              tags: tags,
            ).deep_stringify_keys
            @payment.reload
          end

          it_behaves_like 'レスポンスが正しいこと'
          it_behaves_like 'DBの収支情報が更新されていること', body
        end
      end
    end

    describe '異常系' do
      invalid_attribute = {
        payment_type: [1, 'invalid', ['income'], {type: 'income'}, true],
        date: [1, 'invalid', '1000-13-01', ['1000-01-01'], {date: '1000-01-01'}, true],
        content: [1, '', ['test'], {content: 'test'}, true],
        price: [0, '1', [1], {price: 1}, true],
        categories: [
          'test',
          1,
          {name: 'updated'},
          true,
          [],
          [''],
          [1],
          [%w[updated]],
          [{name: 'updated'}],
          [true],
        ],
        tags: [
          'test',
          1,
          {name: 'updated'},
          true,
          [''],
          ['1' * 11],
          [1],
          [%w[updated]],
          [{name: 'updated'}],
          [true],
        ],
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
          errors.sort_by! {|error| [error['error_code'], error['parameter']] }
          response_body = {'errors' => errors}

          include_context 'トランザクション作成'
          before(:all) { @payment = create(:payment) }
          include_context '収支情報を更新する', body: body
          it_behaves_like 'レスポンスが正しいこと', status: 400, body: response_body
        end
      end

      context 'categoriesに同じ値が指定されている場合' do
        errors = [
          {
            'error_code' => 'include_same_value',
            'parameter' => 'categories',
            'resource' => 'payment',
          },
        ]
        body = {'errors' => errors}
        include_context 'トランザクション作成'
        before(:all) { @payment = create(:payment) }
        include_context '収支情報を更新する', body: {categories: %w[test test]}
        it_behaves_like 'レスポンスが正しいこと', status: 400, body: body
      end

      context 'tagsに同じ値が指定されている場合' do
        errors = [
          {
            'error_code' => 'include_same_value',
            'parameter' => 'tags',
            'resource' => 'payment',
          },
        ]
        body = {'errors' => errors}
        include_context 'トランザクション作成'
        before(:all) { @payment = create(:payment) }
        include_context '収支情報を更新する', body: {tags: %w[test test]}
        it_behaves_like 'レスポンスが正しいこと', status: 400, body: body
      end

      context '複合エラーの場合' do
        errors = [
          {
            'error_code' => 'include_same_value',
            'parameter' => 'categories',
            'resource' => 'payment',
          },
          {
            'error_code' => 'invalid_parameter',
            'parameter' => 'payment_type',
            'resource' => 'payment',
          },
        ]
        response_body = {'errors' => errors}
        request_body = {payment_type: 'invalid', categories: %w[test test]}
        include_context 'トランザクション作成'
        before(:all) { @payment = create(:payment) }
        include_context '収支情報を更新する', body: request_body
        it_behaves_like 'レスポンスが正しいこと', status: 400, body: response_body
      end

      context '存在しないidを指定した場合' do
        include_context '収支情報を更新する', payment_id: 'not_exist'
        it_behaves_like 'レスポンスが正しいこと', status: 404, body: ''
      end
    end
  end
end
