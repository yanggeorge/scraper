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
      html = complete_other_url_path(url, html)
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
    doc,current_url = Nokogiri::HTML(WebAnalysis.instance.click(url, ele_xpath))
    doc = complete_path(current_url, doc)
    doc = delete_tag(doc)
    HtmlManager.instance.add(current_url,doc)
    doc
  end

  def extract(url, xpath)


  end

end
class Rule
  attr_accessor :name
  def initialize(name)
    @name = name
  end

  def analyze(doc)
    puts "rule"
  end
end

class Rule1 < Rule
  def initialize
    super("rule1")
  end

  # check dup tags from top to down, if found return tags list
  def analyze(doc)
    puts "rule 1"
    results = []
    check(doc, results)
    results
  end

  def check(node, results)
    if node and node.is_a? Nokogiri::XML::Node
      elements = node.elements
      if elements.size < 3
        elements.each do |node|
          check(node, results)
        end
      else
        list = get_most_dups(elements)
        if list and list.size > 3
          results << list
        else
          elements.each do |node|
            check(node , results)
          end
        end
      end
    end

  end

  def get_most_dups(nodes)
    hash = {}
    nodes.each do |node|
      feature = get_feature(node)
      if hash.keys.include? feature
        hash[feature] << node
      else
        hash[feature]= [node]
      end
    end

    max = 0
    key = ""
    hash.each do|k,v|
      if v.length > max
        key = k
      end
    end
    hash[key]
  end

  def get_feature(node)
    tag = node.name
    values = node.values
    keys = node.keys
    attributes = node.attributes
    tag
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

  html =<<EOF
<template>
<head></head>
<body>
<div>
<div class="aa"><p>你好</p></div>
<div class="aa"><span><p>大家好</p></span></div>
<div class="aa"><span><p>大家好</p></span></div>
<div class="aa"><span><p>大家好</p></span></div>
</div>
<p></p>
<div>
<div class="aa"><p>你好</p></div>
<div class="aa"><span>
<div class="aa"><span><p>大家好</p></span></div>
<div class="aa"><span><p>大家好</p></span></div>
<div class="aa"><span><p>大家好</p></span></div>
<div class="aa"><span><p>大家好</p></span></div>
<p>大家好</p></span></div>
<div class="aa"><span><p>大家好</p></span></div>
<div class="aa"><span><p>大家好</p></span></div>
<div class="aa"><span><p>大家好</p></span></div>
</div>
</body>
</template>
EOF

  url = "http://www.sd-n-tax.gov.cn/col/col47711/index.template"
  #doc = Nokogiri::HTML(WebAnalysis.instance.get_response(url))
  doc = Nokogiri::HTML(open(url))
  puts doc.to_html

end