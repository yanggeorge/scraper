require File.dirname(__FILE__) + '/../../lib/nokogiri_parse'
require 'uri'
require File.dirname(__FILE__) + "/../models/item"
require File.dirname(__FILE__) + "/../../lib/robot_engine"

class ScrapeController < ApplicationController
  protect_from_forgery with: :null_session

  def do_url
    p params
    @url = params[:url].strip
    @robot_name = params[:robot_name].strip

    new_robot = RPA::RobotService.instance.get_new_robot(@robot_name, @url)
    @robot_string = new_robot.to_one_line
    puts @robot_string
    return @robot_string
  end

  def get_page
    p params
    url = params[:url]
    doc = NokogiriParse.instance.get_doc(url)
    @modified_page = doc.to_html
    puts doc.to_html
    render :json => {:page => @modified_page}
  end

  def valid?(url)
    begin
      uri = URI.parse(url)
      uri.kind_of?(URI::HTTP)
    rescue URI::InvalidURIError
      false
    end
  end

  def save
    puts params
    @status = "true"

    spider_name = params[:spider_name].strip
    puts "spider_name" + spider_name
    begin
      list = params[:list]
      list.each do |k,v|
        puts v
        item = Item.new
        item.spider_name = spider_name
        item.start_url = params[:start_url]
        item.item_xpath = v[:xpath]
        item.item_name = v[:name]
        item.item_example = v[:value]
        item.save
      end
    rescue
      puts "!!!!!!!!!! 保存出错 !!!!!!!!!!!"
      puts $!
      puts $@
      puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
      @status = "false"
    end
    render :json => {:status => @status}
  end


end
