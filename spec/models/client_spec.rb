# coding: utf-8
require 'rails_helper'

describe Client, :type => :model do
  created_client = {:application_id => 'first', :application_key => 'first'}
  expected = 'second'

  before(:all) { Client.create!(created_client) }
  after(:all) { Client.find_by(created_client).destroy }

  describe '::generate_application_id' do
    before(:all) do
      RSpec::Mocks.with_temporary_scope do
        allow(SecureRandom).to receive(:hex).and_return(created_client[:application_id], expected)
        @actual = Client.generate_application_id
      end
    end

    it "#{expected}が返ること" do
      expect(@actual).to eq expected
    end
  end

  describe '::generate_application_key' do
    before(:all) do
      RSpec::Mocks.with_temporary_scope do
        allow(SecureRandom).to receive(:hex).and_return(created_client[:application_key], expected)
        @actual = Client.generate_application_id
      end
    end

    it "#{expected}が返ること" do
      expect(@actual).to eq expected
    end
  end
end
