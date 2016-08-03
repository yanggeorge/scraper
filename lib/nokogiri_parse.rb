require 'singleton'
require 'nokogiri'
require 'open-uri'
require 'uri'
require  File.dirname(__FILE__) + '/web_analysis'

class HtmlManager
  include Singleton

  def initialize
    @links =[]
    @link_doc = {}
    @total_num = 0
    @max_num = 50
    @clear_num = 5
  end

  def add(link, doc)
    unless include? link
      @links << link
      @link_doc[link] = doc
      @total_num += 1
      clear_old if @total_num > @max_num
    end
  end

  def clear_old
    @clear_num.times do
      url = @links.shift
      @link_doc.delete(url)
      @total_num -= 1
    end
  end

  def delete(url)
    if include? url
      @links.delete(url)
      @link_doc.delete(url)
      @total_num -= 1
    end
  end


  def get(url)
    if include? url
      @link_doc[url]
    end
  end

  def include?(url)
    @links.include?url
  end

end

class NokogiriParse
  include Singleton

  def initialize
    url = "http://www.baidu.com"
    doc = Nokogiri::HTML(WebAnalysis.instance.get_response(url)) #just use to try first。
  end

  def get_html(url)
    doc = nil
    if HtmlManager.instance.include? url
      html = HtmlManager.instance.get(url)
    else
      #doc = Nokogiri::HTML(open(url,ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE))   # https简单快速但是有问题，比如baidu的body的display是none
      #puts "using http"
      doc = Nokogiri::HTML(WebAnalysis.instance.get_response(url))
      doc = complete_path(url, doc)
      doc = delete_tag(doc)
      html = doc.to_html
      begin
        html = complete_other_url_path(url, html)
      rescue
        puts "!!!!!!!!!! complete_other_url_path error !!!!!!!!!!!"
        puts $!
        puts $@
        puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
      end
      HtmlManager.instance.add(url,html)
    end
    html
  end

  def complete_path(start_url, doc)
    tags = {
        'img' => 'src',
        'script' => 'src',
        'link' => 'href',
        'iframe' => 'src',
        'meta' => 'url',
        'input' => 'src'
    }

    doc.search(tags.keys.join(',')).each do |node|

      url_param = tags[node.name]

      src = node[url_param]
      if src and (!src.empty?)
        uri = URI.parse(src)
        unless uri.host
          node[url_param] = get_full_path(start_url, uri)
        end
      end
    end

    doc
  end

  def complete_other_url_path(start_url, html)
    html.gsub!(/url\((.*?)\)/){ |m|
      tmp = $1
      if tmp.start_with?("\"")
        tmp.reverse!.chop!
        tmp.reverse!
      end
      if tmp.end_with? "\""
        tmp.chop!
      end
      rep = get_full_path(start_url, tmp)
      m.sub!(tmp,rep)
      m
    }
    html.gsub!(/background\=\"(.*?)\"/){ |m|
      tmp = $1
      rep = get_full_path(start_url, tmp)
      m.sub!(tmp,rep)
      m
    }

    html
  end

  def delete_tag(doc)
    tags = [
        'script'
    ]
    doc.search(tags.join(',')).each do |node|
      node.remove
    end
    doc
  end

  def get_full_path(base_url, path)
    URI.join(base_url, path).to_s
  end

  def click(url, ele_xpath)
    doc,current_url = WebAnalysis.instance.click(url, ele_xpath)
    doc = Nokogiri::HTML(doc)
    doc = complete_path(url, doc)
    doc = delete_tag(doc)
    html = doc.to_html
    begin
      html = complete_other_url_path(url, html)
    rescue
      puts "!!!!!!!!!! complete_other_url_path error !!!!!!!!!!!"
      puts $!
      puts $@
      puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    end
    HtmlManager.instance.add(url,html)
    return doc,current_url
  end

  def extract(url, xpath)
    text = WebAnalysis.instance.extract(url, xpath)
  end

end


class Test

  def test1
    start_url = "http://xkpt.mot.gov.cn/wssq/queryWssqJggs.action?page=1&itemCode=10000704"
    html = NokogiriParse.instance.get_html(start_url)
    puts html
  end

end

if __FILE__== $0

  url = "https://www.wunderground.com/history/airport/ZSHC/2016/1/1/CustomHistory.html?dayend=11&monthend=7&yearend=2016&req_city=&req_state=&req_statename=&reqdb.zip=&reqdb.magic=&reqdb.wmo=&format=1"
  #doc = Nokogiri::HTML(WebAnalysis.instance.get_response(url))
  doc = Nokogiri::HTML(open(url,ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE))
  puts doc.to_html

end