require File.dirname(__FILE__) + '/../../lib/nokogiri_parse'
require 'uri'
require File.dirname(__FILE__) + "/../models/item"
require File.dirname(__FILE__) + "/../../lib/robot_engine"

class ScrapeController < ApplicationController
  protect_from_forgery with: :null_session

  def do_url
    p params
    @url_name = params[:url_name].strip
    @url_value = params[:url_value].strip
    if !valid?(@url_value)
      @is_error = true
      @error_content = "不是合法的url。"
      return @is_error, @error_content
    end
    if !@url_value =~ /^http:|^https:/
      @is_error = true
      @error_content = "请加上http://或者https://"
    end
    begin
      doc = NokogiriParse.instance.get_doc(@url_value)
    rescue
      puts $!
      puts $@
      @is_error = true
      @error_content = "Something is wrong."
      return @is_error, @error_content
    end


    @modified_page = doc.to_html
    puts doc.to_html
    new_robot = RPA::RobotService.instance.get_new_robot(@url_value)
    @robot_string = new_robot.to_one_line
    puts @robot_string
    return @url_name, @url_value, @modified_page, @robot_string
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
