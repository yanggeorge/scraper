class ItemController < ApplicationController
  def index
    @items = Item.all
  end

  def update
    @item = Item.find(params[:id])
    @item.update_attribute :item_name, params[:item][:item_name]
    @item.update_attribute :spider_name, params[:item][:spider_name]
    @item.update_attribute :item_xpath, params[:item][:item_xpath]
    @item.update_attribute :item_example, params[:item][:item_example]
    @item.update_attribute :start_url, params[:item][:start_url]
    redirect_to item_show_path(@item)
  end

  def show
    puts params
    @item = Item.find(params[:id])
  end

  def delete

  end
end
