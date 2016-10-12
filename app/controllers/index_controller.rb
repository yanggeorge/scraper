require File.dirname(__FILE__) + '/../../lib/nokogiri_parse'
require 'uri'
require 'json'
require File.dirname(__FILE__) + "/../models/item"
require File.dirname(__FILE__) + "/../../lib/robot_engine"

class IndexController < ApplicationController
  protect_from_forgery with: :null_session

  def index

  end

  def projects
    all_robots = RobotDataBase.all

    @robots = []
    all_robots.each do |r|
      h = {}
      h["robot_name"] = r.robot_name
      h["robot_id"] = r.robot_id
      @robots << h
    end
    puts @robots.to_json
  end

  def delete_robot
    p params
    @robot_id = params[:robot_id] if params[:robot_id]
    robot_data = RobotDataBase.find_by_robot_id(@robot_id)
    p robot_data
    robot_data.delete

    all_robots = RobotDataBase.all

    @robots = []
    all_robots.each do |r|
      h = {}
      h["robot_name"] = r.robot_name
      h["robot_id"] = r.robot_id
      @robots << h
    end
    @result = @robots.to_json
    render :json => {:result => @result }
  end



end
