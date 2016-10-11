require File.dirname(__FILE__) + '/../../lib/nokogiri_parse'
require 'uri'
require File.dirname(__FILE__) + "/../models/item"
require File.dirname(__FILE__) + "/../../lib/robot_engine"

class ScrapeController < ApplicationController
  protect_from_forgery with: :null_session

  def do_url
    p params
    @url = params[:url].strip if params[:url]
    @robot_name = params[:robot_name].strip if params[:robot_name]
    @robot_id = params[:robot_id].strip if params[:robot_id]
    robot_data = RobotDataBase.find_by_robot_id(@robot_id)
    p
    if robot_data.nil?
      new_robot = RPA::RobotService.instance.get_new_robot(@robot_name, @url)
      @robot_string = new_robot.to_one_line
      puts @robot_string
      return @robot_string
    else
      @robot_string = robot_data.robot_def
      robot = RPA::Robot.from_json_string(@robot_string)
      puts robot.to_s
      RPA::RobotService.instance.register(robot)
      return @robot_string
    end
  end

  def get_page_id
    p params
    url = params[:url]
    html = NokogiriParse.instance.get_html(url)
    puts html
    @id = HtmlManager.instance.get_id(url)
    render :json => {:id => @id}
  end

  def extract_data
    p params
    url = params[:url]
    tag = params[:tag]
    html = NokogiriParse.instance.get_html(url)
    @data = NokogiriParse.instance.extract(url, tag)
    render :json => {:result => @data}
  end

  def click_element
    p params
    url = params[:url]
    xpath = params[:xpath]
    doc, @current_url = NokogiriParse.instance.click(url, xpath)
    @status = "changed"

    # 以下这种情况无法处理ajax动态分页情况，即url地址不变，点击下一页ajax动态加载数据。
    if url == @current_url
      @status = "unchanged"
      render :json => {:status => @status }
    else
      html = NokogiriParse.instance.get_html(@current_url)
      puts html
      @id = HtmlManager.instance.get_id(@current_url)
      render :json => {:id => @id  , :new_url => @current_url, :status => @status }
    end

  end

  def save_robot
    p params
    @status = "true"
    robot_string = params[:robot_string]
    robot =  RPA::Robot.from_json_string(robot_string)
    RPA::RobotService.instance.register(robot)
    begin
      robot_data = RobotDataBase.find_by_robot_id(robot.id)
      if robot_data == NIL
        robot_data = RobotDataBase.new
        robot_data.robot_id = robot.id
        robot_data.robot_name = robot.name
        robot_data.deleted = robot.deleted
        robot_data.robot_def = robot.to_one_line
      else
        robot_data.robot_name = robot.name
        robot_data.deleted = robot.deleted
        robot_data.robot_def = robot.to_one_line
      end
      p robot_data
      robot_data.save!
    rescue
      puts "!!!!!!!!!! 保存出错 !!!!!!!!!!!"
      puts $!
      puts $@
      puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
      @status = "false"
    end


    render :json => {:result => @status}
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

  def page
    puts params
    html = HtmlManager.instance.get_by_id(params[:id])
    if html
      render html: html.html_safe
    else
      render html: ''
    end
  end

end
