# 产生 各个step的svg图的实例

class Node_svg
  from_node : ""  # node_id
  to_node :""     # 指向的node的id
  id: ""
  svg_id : ""
  marker_id : ""
  path_id : ""
  is_end : false
  is_active : false
  color : ""
  points : ""

  constructor : (from_node_id, to_node_id="")->
    @from_node = from_node_id
    @to_node = to_node_id
    @id = Math.uuid()
    @svg_id = Math.uuid()
    @marker_id = Math.uuid()
    @path_id = Math.uuid()
    @is_end = false
    @is_active = false
    @color = @init_color()
    @points = ""

  init_color : ->
    if @is_active
      @color = "#2ecc71"
    else
      @color = "#666"

  to_s: ->
    return "from_node:" + @from_node + ",to_node:" + @to_node + ",points:" + @points

namespace = (target, name, block) ->
  [target, name, block] = [(if typeof exports isnt 'undefined' then exports else window), arguments...] if arguments.length < 3
  top = target
  target = target[item] or= {} for item in name.split '.'
  block target, top

namespace "ym.rpa", (exports) ->
  exports.Node_svg = Node_svg
