# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  window.ym.mos.SetCallback(dealXpathValue)
  window.ym.mos.SetupDOMSelection()
  $("#reSelect").click =>
    window.ym.mos.SetupDOMSelection()


dealXpathValue = (xpath ,value) ->
  console.log(xpath)
  console.log(value)
  state =
    state0 :
      title : '抓取变量'
      html : '<div style="vertical-align: middle"><label>name :</label><br/><input type="text" name="name" size="30" value=""><br />' +
              '<label>xpath :</label><br/><input type="text" name="xpath" size="50" value="' + xpath + '"><br />' +
        '<label style="vertical-align: middle">value:</label><br/><textarea name="text" rows="4" cols="50">
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
          submit_form(f)
        else
          window.ym.mos.SetupDOMSelection()
        e.preventDefault()
        $.prompt.close()

  $.prompt(state)


submit_form = (form) ->
  option =
    url : "/scrape/save"
    type : "post"
    data : form
    success : (data) ->
      console.log(data)
      return false
    error:(data)->
      return false

  $.ajax(option)