
# step 对应的页面上的节点描述类
class TreeNode
  id : ""
  name : ""
  tags : ""
  kind : ""
  style : ""

  constructor : () ->
    @id = ""
    @name = ""
    @tags = ""
    @kind = ""
    @style = ""


namespace = (target, name, block) ->
  [target, name, block] = [(if typeof exports isnt 'undefined' then exports else window), arguments...] if arguments.length < 3
  top = target
  target = target[item] or= {} for item in name.split '.'
  block target, top

namespace "ym.rpa", (exports) ->
  exports.TreeNode = TreeNode
