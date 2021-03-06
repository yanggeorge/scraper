#encoding: utf-8
require 'selenium-webdriver'
require 'singleton'
require 'fileutils'
require 'socket'
require 'timeout'
require 'os'

class WebAnalysis
  include Singleton
  attr_accessor :url , :body , :driver

  def initialize
    phantomjs = Rails.configuration.scraper['phantomjs_full_path']
    #phantomjs = 'c:\mybin\phantomjs-2.1.1-windows\bin\phantomjs.exe'
    use_proxy = Rails.configuration.scraper['use_proxy']
    #use_proxy = nil
    run_phntomjs(phantomjs)
    if OS.linux?
      set_global_http_proxy_null
    end
    if not use_proxy
      puts 'not use proxy'
      @driver = Selenium::WebDriver.for(:remote,
                                        :url => "http://localhost:9134")
    else
      http_proxy = Rails.configuration.scraper['http_proxy']
      puts "use #{http_proxy}"

      proxy = Selenium::WebDriver::Proxy.new(
          :http     =>  http_proxy
      )
      caps = Selenium::WebDriver::Remote::Capabilities.ie(:proxy => proxy)
      @driver = Selenium::WebDriver.for(:remote,
                                        :url => "http://localhost:9134",
                                        :desired_capabilities => caps)
    end
      puts "WebAnalysis is initializing.(#{phantomjs})"
  end

  def run_phntomjs(phantomjs)
    Thread.new { `#{phantomjs} --webdriver=9134` } # 首先运行phantomjs
    #sleep 5 #等待启动时间
    print "Waiting"
    for i in 1..30
      print "."
      sleep 1
      if is_port_open?("127.0.0.1", "9134") == true
        break
      end
    end
    if is_port_open?("127.0.0.1", "9134") == false
      puts "phantomjs has not opened port 9134!!!"
    else
      puts "phantomjs has opened port 9134."
    end
  end

  def is_port_open?(ip, port)
    begin
      Timeout::timeout(1) do
        begin
          s = TCPSocket.new(ip, port)
          s.close
          return true
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
          return false
        end
      end
    rescue Timeout::Error
    end

    return false
  end

  def set_global_http_proxy_null
    # on linux, export http_proxy=""
    env_http_proxy = ENV['http_proxy']
    if env_http_proxy
      puts "Set global http_proxy nil."
      ENV['http_proxy'] = nil
    end

  end

  def test
    @driver.navigate.to "http://google.com"
    element = @driver.find_element(:name, 'q')
    element.send_keys "PhantomJS"
    element.submit
    puts @driver.title
  end

  def get_response(url=nil)
    page_source = nil
    if url == nil
      @driver.navigate.to "http://www.he-n-tax.gov.cn/hbgsww_new/hbgsgkml/ajxxgk/880/list.htm"
    else
      # 这里容易产生 ReadTimeout的问题
      begin
        @driver.navigate.to url
      rescue
        puts "!!!!!!!!!! get response error !!!!!!!!!!!"
        puts $!
        puts $@
        puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
      end

    end
    page_source = @driver.page_source
    page_source
  end

  def click(url , ele_xpath)
    page_source = nil
    current_url = nil

    @driver.navigate.to url
    @driver.manage.window.maximize # because some element not visible ,then cannot click
    element = @driver.find_element(:xpath,ele_xpath)
    p element


    puts "element.text = #{element.text}"
    element.click
    main_handle = @driver.window_handle
    p main_handle
    handles = @driver.window_handles
    p handles
    # 有的网站点击一次之后会弹出一个新的窗口，所以这时handles的长度是2
    # 当长度大于1的时候，则在获取新打开窗口的page_source和之后，再切换回
    # 原来的窗口。
    if handles.length > 1
      @driver.switch_to.window handles[-1]
      page_source,current_url =  @driver.page_source, @driver.current_url
      @driver.close
      @driver.switch_to.window main_handle
    else
      page_source,current_url =  @driver.page_source, @driver.current_url
    end

    return page_source,current_url
  end

  def extract(url, ele_xpath)
    text = nil
    @driver.navigate.to url
    element = @driver.find_element(:xpath,ele_xpath)
    text = element.text

    text
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
    # @page_source = page_source
    # @start_url = (start_url == "" ? "http://www.he-n-tax.gov.cn/hbgsww_new/hbgsgkml/ajxxgk/880/list.htm" : start_url)
    # @css_file = fetch_css_style
    # PageSourceManager.instance.add(@start_url, @page_source, @css_file)
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

    css.gsub!(/<template.*?>|<head.*?>|<body.*?>|<pre.*?>/,"")
    css.gsub!(/<\/template>|<\/head>|<\/body>|<\/pre>/,"")
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

def test
  url = "http://www.he-n-tax.gov.cn/hbgsww_new/"
  xpath = "//html[1]/body[1]/div[2]/div[2]/div[2]/div[2]/div[1]/div[1]/ul[1]/li[1]/a[1]"
  _,current_url = WebAnalysis.instance.click(url, xpath)
  puts current_url
  url = "http://www.he-n-tax.gov.cn/hbgsww_new/"
  xpath = "//html[1]/body[1]/div[2]/div[2]/div[2]/div[2]/div[1]/div[1]/ul[1]/li[1]/a[1]"
  _,current_url = WebAnalysis.instance.click(url, xpath)
  puts current_url

  url = "http://www.baidu.com"
  xpath = "//html[1]/body[1]/div[3]/div[1]/div[1]/div[3]/a[3]"
  _,current_url = WebAnalysis.instance.click(url, xpath)
  puts current_url

end

def test1
  url = "http://www.baidu.com/"

  HtmlAnalysis.instance.analyze(url)
  page_source = HtmlAnalysis.instance.page_source
  puts page_source
end

def test2
  base_url = "http://www.he-n-tax.gov.cn/hbgsww_new/"
  path = "\"gdot_ico.jpg\""
  if path.start_with?("\"")
    path.reverse!.chop!
    path.reverse!
  end
  if path.end_with? "\""
    path.chop!
  end

  puts URI.join(base_url, path).to_s

end

def test3
  url = "http://threelambda.com"
  #url = "http://www.baidu.com"
  xpath = "//html[1]/body[1]/header[1]/div[1]/nav[1]/div[1]/a[1]"
  #xpath = "//html[1]/body[1]/main[1]/div[1]/div[1]/ul[1]/li[1]/h2[1]/a[1]"

  _,current_url = WebAnalysis.instance.click(url, xpath)
  puts current_url
end

if __FILE__==$0

  test3



end