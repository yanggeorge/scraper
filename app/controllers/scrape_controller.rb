require File.dirname(__FILE__) + '/../../lib/web_analysis'
require 'uri'
require File.dirname(__FILE__) + "/../models/item"

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
      HtmlAnalysis.instance.analyze(@url_value)
    rescue
      puts $!
      puts $@
      @is_error = true
      @error_content = "Something is wrong."
      return @is_error, @error_content
    end

    @css =HtmlAnalysis.instance.css_file
    @modified_page = HtmlAnalysis.instance.modified_page
    return @url_name, @url_value, @modified_page, @css
  end

  def valid?(url)
    uri = URI.parse(url)
    uri.kind_of?(URI::HTTP)
  rescue URI::InvalidURIError
    false
  end

  def save
    puts params
    @status = "true"
    begin
      item =  Item.new
      item.item_name = params[:name].strip
      item.item_xpath = params[:xpath].strip
      item.spider_name = "test"
      item.save
    rescue
      @status = "false"
    end
    render :json => { :status => @status}
  end

end
