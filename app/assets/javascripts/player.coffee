
class Player
  play_step_ids : []
  play_steps : []
  next : ""
  current : ""
  playing : false
  first : ""
  pages : []
  outputs : {}
  is_end : false

  constructor : (robot)->
    @play_step_ids = []
    @play_steps = []
    @next = null
    @current = ""
    @playing = false
    @first = ""
    @pages = []
    @outputs = {}
    @is_end =false
    @init(robot)

  init : (robot)->
    id = robot.first_step
    pre_id = ""
    is_first = true
    while true
      @play_step_ids.push(id)
      play_step = new ym.rpa.PlayStep()
      play_step.step = robot.steps[id]
      if is_first
        play_step.pre = null
        is_first = false
      else
        play_step.pre = robot.steps[pre_id]

      next_step_ids = robot.steps[id].next
      if next_step_ids.length > 0
        pre_id = id
        id = next_step_ids[0]
        play_step.next = robot.steps[id]
        @play_steps.push(play_step)
      else
        play_step.next = null
        @play_steps.push(play_step)
        break

    @current = @play_steps[0]
    @next = @play_steps[1]
    @first = @play_steps[0]
    for id in Object.keys(robot.outputs)
      @outputs[id] = robot.outputs[id]


  #当robot更新的时候，需要刷新player
  # 对于旧的play序列 1,2,3,4,5, current=4,
  # 当序列变为 1,2,4,5 ，则current = 4，并且4的pre_state = 2的post_state
  # 所以更新前，先备份play_steps ，更新后，与备份的序列从开始进行比较id，
  # 从而设置正确的current，并保留已运行state
  #
  # 需要注意的是 当一个robot的step的值进行edit，那么id未变化
  # 则current需要根据变化的step的位置进行重新定位
  fresh_with : (robot) ->
    old_play_step_ids = @play_step_ids
    console.log(old_play_step_ids)
    old_play_steps = @play_steps
    old_current = @current
    console.log("old")
    console.log(old_current.step.id)


    @play_step_ids = []
    @play_steps = []

    @init(robot)

    if old_current.step.id in @play_step_ids
      console.log("yes")
    else
      console.log("no")

    # 更新current并保留state
    i = 0
    while old_play_step_ids[i] == @play_step_ids[i] and i < old_play_step_ids.length and i < @play_step_ids.length
      @play_steps[i].pre_state = old_play_steps[i].pre_state
      @play_steps[i].post_state = old_play_steps[i].post_state
      i = i + 1

    stop = i
    if stop == 0
      # 说明说明first发生改变。
    else
      n = @play_step_ids.indexOf(old_current.step.id)
      if n > 0 and n < stop
        @current = @play_steps[n]
        pre = @play_steps[n - 1]
        @current.pre_state = pre.post_state
      else if n > 0
        # n > 0 且 大约 stop，说明当前的node之前插入了新的node。
        @current = @play_steps[stop]
        pre = @play_steps[stop - 1]
        @current.pre_state = pre.post_state
      else if n < 0 and @is_end == false
        # 说明删除的是current节点
        @current = @play_steps[stop]
        pre = @play_steps[stop - 1]
        @current.pre_state = pre.post_state
      else if n < 0 and @is_end == true
        # 说明删除的是最后一个节点。
        @current = @play_steps[stop - 1]
        pre = @play_steps[stop - 2]
        @current.pre_state = pre.post_state

      @next = @play_steps[@play_step_ids.indexOf(@current.step.id) + 1]
      if @current.step.id != @play_steps[(@play_step_ids.length) - 1].step.id
        @is_end = false   #可以判断是否是非结尾。
      else
        #@is_end = true  #无法通过current来判断是否end，因为当end的时候，current指向最后一个节点
        @next = null







  # 需要注意的是 当一个robot的step的值进行edit，那么id未变化
  # 则current需要根据变化的step的位置进行重新定位
  relocate_current : (step_id)->
    old_current = @current

    stop = @play_step_ids.indexOf(step_id)
    if stop == 0
      # 说明说明first发生改变。
      @current = @play_steps[0]
    else
      j = 0
      while j < stop
        if @play_step_ids[j] == old_current.step.id
          break
        j = j + 1
      if j == stop
        @current = @play_steps[j]
      else
        @current = old_current

  restart_init : ->
    @first = @play_steps[0]
    @next = @play_steps[1]
    @current =  @play_steps[0]
    @is_end = false
    @playing = false

  pre_step : ->
    # 当is_end为真的时候，current指向最后一个节点，因为无法再向下移动，也没有
    # 指向null，因为这样不方便查找pre_step.
    # 因此，不需要移动current的指向。
    if @is_end == true
      @is_end = false
      return

    if @current == @first
      return
    else
      @next = @current
      @current = @play_steps[@play_step_ids.indexOf(@current.step.id)-1]

namespace = (target, name, block) ->
  [target, name, block] = [(if typeof exports isnt 'undefined' then exports else window), arguments...] if arguments.length < 3
  top = target
  target = target[item] or= {} for item in name.split '.'
  block target, top

namespace "ym.rpa", (exports) ->
  exports.Player = Player