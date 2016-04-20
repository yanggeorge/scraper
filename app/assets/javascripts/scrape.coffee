# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

window.ym.xpath_container="//div[@id='modified_page']";

jQuery(document).ready ->
  init_scraped_table()
  window.ym.mos.SetCallback(dealXpathValue)
  jQuery("#reSelect").click =>
    window.ym.mos.SetupDOMSelection(window.ym.xpath_container)
  jQuery("#scraped_data_submit").click =>
    submit_scraped_data()


init_scraped_table = ->
  window.ym.tbl = new window.ym.ScrapedTable
  rerender_scraped_table(window.ym.tbl)

rerender_scraped_table = (tbl)->
  jQuery("#scraped_data").html(tbl.to_html())
  window.ym.mos.SetupDOMSelection(window.ym.xpath_container)

window.ym.deleteItem = (id) ->
  console.log("deleteItem")
  if (window.ym.tbl)
    window.ym.tbl.remove(id)
    rerender_scraped_table(window.ym.tbl)

window.ym.addItem = (item) ->
  if (window.ym.tbl)
    window.ym.tbl.add(item)
    rerender_scraped_table(window.ym.tbl)

dealXpathValue = (xpath ,value) ->
  console.log(xpath)
  console.log(value)
  state =
    state0 :
      title : '抓取变量'
      html : '<div style="vertical-align: middle"><label>name :</label><br/><input type="text" name="name" size="30" value=""><br />' +
              '<label>xpath :</label><br/><input type="text" name="xpath" size="50" value="' + xpath + '"><br />' +
        '<label style="vertical-align: middle">value:</label><br/><textarea name="value" rows="4" cols="50">
' + value + '
</textarea></div>'
      buttons :
        "保存" : 1
        "取消" : 0
      submit : (e,v,m,f)->
        console.log(f)
        console.log(v)
        console.log(m)
        if v == 1
          item = new window.ym.ScrapedItem(f.name,f.value,f.xpath)
          window.ym.addItem(item)
          window.ym.mos.SetupDOMSelection(window.ym.xpath_container)
        else
          window.ym.mos.SetupDOMSelection(window.ym.xpath_container)
        e.preventDefault()
        $.prompt.close()

  $.prompt(state)

submit_scraped_data = ->
  tbl_data = window.ym.tbl.to_list()
  if tbl_data.length == 0
    alert("No data to save!")
    return

  state =
    state0 :
      title : '填写爬虫的英文名称'
      html : '<div style="vertical-align: middle"><label>spider_name :</label><br/><input type="text" name="spider_name" size="30" value=""><br /></div>'
      buttons :
        "保存" : 1
        "取消" : 0
      submit : (e,v,m,f)->
        if v == 1
          _submit_scraped_data(f.spider_name)
        else
          window.ym.mos.SetupDOMSelection(window.ym.xpath_container)
        e.preventDefault()
        $.prompt.close()

  jQuery.prompt(state)

_submit_scraped_data = (spider_name) ->
  tbl_data = window.ym.tbl.to_list()
  data =
    "spider_name" : spider_name
    "list" : tbl_data

  option =
    url : "/scrape/save"
    type : "post"
    data : data
    success : (data) ->
      console.log(data)
      window.ym.tbl.clear()
      rerender_scraped_table(window.ym.tbl)
      return false
    error:(data)->
      return false

  $.ajax(option)


class window.ym.ScrapedItem
  constructor: (@name, @value, @xpath)->

  getName: ->
    @name
  getValue: ->
    @value
  getXpath: ->
    @xpath
  setName: (name) ->
    @name = name
  setXpath: (xapth)->
    @xpath = xpath
  setValue: (value)->
    @value = value
  to_html: ->
    html = '<td>' + @name + '</td><td>' + @value + '</td><td>' + @xpath + '</td>'
    html

class window.ym.ScrapedTable
  constructor: ->
    @list = []

  add: (item)->
    @list.push(item)

  remove: (id)->
    @list.splice(id-1,1)

  clear:->
    @list = []

  to_html: ->
    html = '<table class="gridtable">
    <thead>
    <tr>
    <th>
    序号
    </th>
    <th>
      name
    </th>
    <th>
    value
    </th>
    <th>
      xpath
    </th>
    <th>
    操作
    </th>
        </tr>
    </thead>'
    i = 1
    for item in @list
      html += '<tr><td>' + i + '</td>' + item.to_html() + '<td><a href="#" onclick="javascript:window.ym.deleteItem('+ i + ');return false;" id="item' + i + '">delete</a></td></tr>'
      i += 1
    html += '</table>'

  to_list : ->
    i = 1
    list = []
    for item in @list
      data =
        "name" : item.getName()
        "value" : item.getValue()
        "xpath" : item.getXpath()
      list.push(data)
    list

