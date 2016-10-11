require File.dirname(__FILE__) + '/../../lib/nokogiri_parse'
require 'uri'
require 'json'
require File.dirname(__FILE__) + "/../models/item"
require File.dirname(__FILE__) + "/../../lib/robot_engine"

class IndexController < ApplicationController

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
end
