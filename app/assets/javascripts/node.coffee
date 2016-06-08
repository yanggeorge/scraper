
# step 对应的页面上的节点描述类
class Node
  id : ""
  title : ""
  desc : ""
  left : 0
  right:0
  width : 0
  height : 0
  position : ""
  is_end : false

  constructor : (title) ->
    @id = ""
    @title = title
    @desc = ""
    @left = 0
    @right = 0
    @width = 0
    @height = 0
    @position = ""
    @is_end = false

  to_s : ->
    @title + "," + @desc + "," + @position

  compute_position: ->
    @position =
      left: @left + 'px'
      top: @top + 'px'
      width: @width + 'px'
      height: @height + 'px'


namespace = (target, name, block) ->
  [target, name, block] = [(if typeof exports isnt 'undefined' then exports else window), arguments...] if arguments.length < 3
  top = target
  target = target[item] or= {} for item in name.split '.'
  block target, top

namespace "ym.rpa", (exports) ->
  exports.Node = Node
