#encoding: utf-8
require 'selenium-webdriver'
require 'singleton'
require 'fileutils'


class WebAnalysis
  include Singleton
  attr_accessor :url , :body , :driver

  def initialize
    @driver = Selenium::WebDriver.for(:remote, :url => "http://localhost:9134")
  end

  def test
    @driver.navigate.to "http://google.com"
    element = @driver.find_element(:name, 'q')
    element.send_keys "PhantomJS"
    element.submit
    puts @driver.title
  end

  def get_response(url=nil)
    if url == nil
      @driver.navigate.to "http://www.he-n-tax.gov.cn/hbgsww_new/hbgsgkml/ajxxgk/880/list.htm"
    else
      @driver.navigate.to url
    end
    @driver.page_source
  end

end

class PageSourceManager
  include Singleton
  def initialize
    @links = []
    @hash_pagesource = {}
    @hash_css_file = {}
    @total_num = 0
    @max = 20
  end

  def add(url, page_source, css_file)
    if @links.include?(url)
      @links << url
      @hash_pagesource[url] = page_source
      @hash_css_file[url] = css_file
      @total_num += 1
      while @total_num >= @max
        url = @links.shift
        @hash_pagesource.delete(url)
        @hash_css_file.delete(url)
        @total_num -= 1
      end
    end
  end

  def remove_by_url(url)
    if @links.include?(url)
      @hash_pagesource.delete(url)
      @hash_css_file.delete(url)
      @links.delete(url)
      @total_num -= 1
    end
  end

  def get_page_source(url)
    page = ""
    if @links.include?url
      page =@hash_pagesource[url]
    end
    page
  end

  def get_css_file(url)
    css_file = ""
    if @links.include?url
      css_file =@hash_css_file[url]
    end
    css_file
  end

  def include?(url)
    @links.include?(url)
  end

end

class HtmlAnalysis
  attr_accessor :page_source , :start_url, :css_file, :modified_page
  include Singleton

  def initialize(page_source=nil,start_url="")
    @page_source = page_source
    @page_source = init_with_file  if page_source == nil
    @start_url = (start_url == "" ? "http://www.he-n-tax.gov.cn/hbgsww_new/hbgsgkml/ajxxgk/880/list.htm" : start_url)
    @css_file = fetch_css_style
    PageSourceManager.instance.add(@start_url, @page_sourcek, @css_file)
  end

  def analyze(start_url)
    if PageSourceManager.instance.include?(start_url)
      @start_url = start_url
      @page_source = PageSourceManager.instance.get_page_source(start_url)
      @css_file = PageSourceManager.instance.get_css_file(start_url)
    else
      @start_url = start_url
      @page_source = WebAnalysis.instance.get_response(@start_url)
      @css_file = fetch_css_style
      PageSourceManager.instance.add(start_url, @page_source, @css_file)
    end

    @modified_page = modify(@start_url, @page_source)
  end

  def modify(start_url, page_source)
    page = complete_url(@start_url, @page_source)
    remove_css_link(page)
  end

  # complete the src url of iframe and
  def complete_url(start_url, page_source)
    page_source.gsub!(/<iframe.*?src\=\"(.*?)\">/){ |m|
      tmp = $1
      if tmp =~ /^\.\./
        rep = get_full_path(start_url, tmp)
      else
        rep = get_full_path_2(start_url, tmp)
      end
      m.sub!(tmp,rep)
      puts m
      m
    }
    # url(../../fdfa.jpg)
    page_source.gsub!(/url\(\"?(.*?)\"?\)/i){ |m|
      tmp = $1
      if tmp =~ /^\.\./
        rep = get_full_path(start_url, tmp)
      else
        rep = get_full_path_2(start_url, tmp)
      end
      m.sub!(tmp,rep)
      puts m
      m
    }
    page_source
  end

  def get_full_path_2(start_url, path)
    full_path = ""
    head = ""
    if start_url =~ /^http:/
      start_url.sub!(/http:\/\//,"")
      head = "http://"
    elsif start_url =~ /^https:/
      start_url.sub!(/https:\/\//,"")
      head = "https://"
    else
      head = "http://"
    end
    ss = start_url.split("/")
    ss.each do |s|
      if s =~ /\..*?\./
        full_path =head + s + path
        break
      end
    end
    full_path
  end

  def remove_css_link(page)
    page.gsub(/<link.*?>/,"")
  end

  def init_with_file
    f = File.open(File.dirname(__FILE__) + "./sample.html" , "r:UTF-8")
    puts f.path
    page_source ||= ""
    f.each do |line|
      page_source += line
    end
    page_source.gsub!(/<!--.*?-->|<script.*?script>/m,"")
    # page_source.gsub!(/<style.*?style>/m,"")
    # page_source.gsub!(/<head.*?head>/m,"")
    # page_source.gsub!(/<html.*?>/m,"")
    # page_source.gsub!(/<body.*?>/m,"")
    # page_source.gsub!(/<\/body>/m,"")
    # page_source.gsub!(/<\/html>/m,"")
    page_source
  end

  def fetch_css_style
    css = ""
    csslinks = get_all_css_link(@page_source)
    csslinks.each do |url|
      body = WebAnalysis.instance.get_response(url)
      body.gsub!(/url\('?(.*?)'?\)/){|m|
        tmp = $1
        rep = get_full_path(url,tmp)
        m.sub(tmp,rep)
      }
      css += body
      css += "\n"
    end

    css.gsub!(/<html.*?>|<head.*?>|<body.*?>|<pre.*?>/,"")
    css.gsub!(/<\/html>|<\/head>|<\/body>|<\/pre>/,"")
    css.gsub!(/\/\*.*?\*\//,"")
    css
  end

  def get_all_css_link(s)
    links = []
    s.scan(/<link\s+href=\"(.*?)\"/).each do |path|
      url = get_full_path(@start_url, path[0])
      links << url
    end
    puts "css_link"
    puts  links
    links
  end

  def get_full_path(start_url, path)
    return path if path.strip! =~ /^http/i
    full_path = ""
    head = ""
    if start_url =~ /^http:/
      start_url.sub!(/http:\/\//,"")
      head = "http://"
    elsif start_url =~ /^https:/
      start_url.sub!(/https:\/\//,"")
      head = "https://"
    else
      head = "http://"
    end

    parts = start_url.split("/")
    paths = path.split("/")
    parts.pop # drop file name

    while !paths.empty?
      a = paths.shift
      if a == ".."
        parts.pop
      else
        parts << a
      end
    end

    full_path = head + parts.join("/")
  end

end

if __FILE__==$0

  #s =  HtmlAnalysis.instance.page_source

  #puts HtmlAnalysis.instance.fetch_css_style
  url = "http://www.baidu.com/"

  HtmlAnalysis.instance.analyze(url)
  page_source = HtmlAnalysis.instance.page_source
  puts page_source
end