
#与robot的step action不同， 播放步骤包含更多的状态信息。
# pre_state 是运行该步骤钱的全局状态
# post_state 是运行该步骤后的全局状态
class PlayStep
  step : ""
  next : ""
  pre : ""
  pre_state : ""
  post_state : ""

  constructor : ->
    @step = ""
    @next = ""
    @pre = ""
    @pre_state = ""
    @post_state = ""


namespace = (target, name, block) ->
  [target, name, block] = [(if typeof exports isnt 'undefined' then exports else window), arguments...] if arguments.length < 3
  top = target
  target = target[item] or= {} for item in name.split '.'
  block target, top

namespace "ym.rpa", (exports) ->
  exports.PlayStep = PlayStep