# coding: utf-8
class Statistics::SettlementsController < ApplicationController
  def show
    settlements = [].tap do |array|
      Payment.settle('monthly').each do |date, price|
        array << {:date => date, :price => price}
      end
    end
    render :status => :ok, :json => settlements
  end
end
