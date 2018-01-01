# coding: utf-8
class Statistics::SettlementsController < ApplicationController
  def show
    render :status => :ok, :json => Payment.settle('monthly')
  end
end
