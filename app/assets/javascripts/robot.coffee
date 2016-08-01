
# module public variable to be in exports
ACTION_VISIT = "VISIT"
ACTION_CLICK = "CLICK"
ACTION_EXTRACT = "EXTRACT"
ACTION_FLUSH = "FLUSH"
ACTION_NOTHING = "NOTHING"

#module private variable
INDENT  = "    "
ACTIONS = ["VISIT", "CLICK", "EXTRACT", "FLUSH", "NOTHING"]

class Robot
  first_step: ""
  steps : {}
  outputs :{}
  name : ""
  id : ""
  deleted : false

  constructor : (name)->
    @steps = {}
    @outputs = {}
    @name = name
    @id = Math.uuid()
    @deleted = false

  @from_json_string : (json_string)->
    jo = JSON.parse(json_string)
    robot = new Robot("")
    robot.first_step = jo["first_step"]
    steps =  jo["steps"]
    for id1 in Object.keys(steps)
      robot.steps[id1] = Step.from_hash(steps[id1])
    outputs = jo["outputs"]
    for id2 in Object.keys(outputs)
      robot.outputs[id2] = Output.from_hash(outputs[id2])

    robot.name = jo["name"]
    robot.id = jo["id"]
    console.log(jo["deleted"])
    robot.deleted = (jo["deleted"] == "true" ) ? true : false
    robot

  to_s : (indent = INDENT)->
    s = "{\n"
    s += indent + @first_step_to_s() + ",\n" if @first_step
    s += indent + @steps_to_s(indent + INDENT) + ",\n"
    s += indent + @outputs_to_s(indent + INDENT) + ",\n"
    s += indent + @name_to_s() + ",\n"
    s += indent + @id_to_s() + ",\n"
    s += indent + @deleted_to_s() + "\n" # <--- 最后一个没有逗号
    s += "}\n"

  first_step_to_s : ->
    "\"first_step\":\"#{@first_step}\""

  steps_to_s : (indent=INDENT)->
    s = ""
    if Object.keys(@steps).length == 0
      s += "\"steps\":{}"
    else
      s += "\"steps\":{\n"
      i = 1
      for id in Object.keys(@steps)
        s += indent + @steps[id].to_s(indent + INDENT)
        if i != Object.keys(@steps).length
          s += ",\n"
        else
          s += "\n"
        i += 1
      s += indent +  "}"
    s

  outputs_to_s : (indent = INDENT)->
    s = ""
    if Object.keys(@outputs).length == 0
      s += "\"outputs\":{}"
    else
      s += "\"outputs\":{\n"
      i = 1
      for id in  Object.keys(@outputs)
        s += indent + @outputs[id].to_s(indent+ INDENT)
        if i == Object.keys(@outputs).length
          s += "\n"
        else
          s += ",\n"
        i += 1
      s += indent + "}"
    s

  name_to_s : ->
    "\"name\":\"#{@name}\""

  id_to_s : ->
    "\"id\":\"#{@id}\""

  deleted_to_s : ->
    "\"deleted\":\"#{@deleted}\""

  #在current_step之前添加step
  add_step_before:(step, current_step)->
    if current_step.id not in Object.keys(@steps)
      console.log("current step is not exist.")
      throw "add_step_before error"
      return false
    if step.id in Object.keys(@steps)
      console.log("step is just in Robot.\n" + this.to_s())
      throw "add_step_before error"
      return false

    current_step_id = current_step.id
    before_step_id = ""
    for id in Object.keys(@steps)
      if current_step_id in @steps[id].next
        before_step_id = id
        break

    if before_step_id == ""
      @steps[step.id] = step
      step.next.push(current_step_id)
      @first_step = step.id
    else
      list = @steps[before_step_id].next
      index = list.indexOf(current_step_id)
      if index > -1
        list.splice(index,1)
      list.push(step.id)
      @steps[step.id] = step
      step.next.push(current_step_id)
    return true

  #在current_step之后添加step
  add_step_after : (step, current_step) ->
    if current_step.id not in Object.keys(@steps)
      console.log("current step is not exist.")
      throw "add_step_after error"
      return false
    if step.id in Object.keys(@steps)
      console.log("step is just in Robot.\n" + this.to_s())
      throw "add_step_after error"
      return false

    current_step_id = current_step.id
    after_step_id_list = @steps[current_step_id].next
    @steps[step.id] = step
    step.next = after_step_id_list
    @steps[current_step_id].next = []
    @steps[current_step_id].next.push(step.id)

    return true

  remove_step : (step) ->
    if step.id not in Object.keys(@steps)
      console.log("step is not in Robot.\n")
      throw "remove_step error"
      return

    before_step_id = ""
    for id1 in Object.keys(@steps)
      if step.id in @steps[id1].next
        before_step_id = id1
        break
    if before_step_id == ""
      list = step.next
      if list.length > 1
        console.log("step has more than 1 next step.")
        throw "remove_step error"
        return false
      else if list.length == 0
        console.log("step has 0 next step.")
        throw "remove_step error"
        return false
      @first_step = list[0]
      delete @steps[step.id]
    else
      after_step_id_list = step.next
      before_step = @steps[before_step_id]
      list = before_step.next
      index = list.indexOf(step.id)
      if index > -1
        list.splice(index, 1)
      for id2 in after_step_id_list
        list.push(id2)
      delete @steps[step.id]

    return true

  add_output : (output) ->
    @outputs[output.id] = output

  remove_output : (output) ->
    delete @outputs[output.id]

class Step
  id: ""
  action: ""
  title : ""
  field : ""
  value : ""
  tags : []
  next : []
  options : []
  error_message : ""

  @from_hash: (hash)->
    step = new Step(hash["action"])
    step.id = hash["id"]
    step.title = hash["title"]
    step.field = hash["field"]
    step.value = hash["value"]
    step.tags = hash["tags"]
    step.next = hash["next"]
    step.options = hash["options"]
    step.error_message = hash["error_message"]
    step

  constructor: (action)->
    @id = Math.uuid()
    if action in ACTIONS
      @action = action
    else
      @action = ACTION_VISIT
    @title = @init_title(@action)
    @field = ""
    @value = ""
    @tags = []
    @next = []
    @options = []
    @error_message = ""

  init_title : (action) ->
    if action == ACTION_VISIT
      return "Go to URL"
    else if action == ACTION_EXTRACT
      return "Extract"
    else if action == ACTION_FLUSH
      return "Save"
    else if action == ACTION_CLICK
      return "Click"
    else if action == ACTION_NOTHING
      return "Do Nothing"

  # step只是一部分
  to_s: (indent = INDENT) ->
    s = "\"#{@id}\":{\n"
    s += indent + @id_to_s() + ",\n"
    s += indent + @action_to_s() + ",\n"
    s += indent + @title_to_s() + ",\n"
    s += indent + @field_to_s() + ",\n"
    s += indent + @value_to_s() + ",\n"
    s += indent + @tags_to_s(indent + INDENT) + ",\n"
    s += indent + @next_to_s(indent + INDENT) + ",\n"
    s += indent + @options_to_s(indent + INDENT) + ",\n"
    s += indent + @error_message_to_s() + "\n"
    s += indent + "}"
    s

  action_to_s : ->
    "\"action\":\"#{@action}\""


  title_to_s : ->
    "\"title\":\"#{@title}\""

  field_to_s : ->
    "\"field\":\"#{@field}\""

  next_to_s : (indent = INDENT) ->
    s = ""
    if Object.keys(@next).length == 0
      s += "\"next\":[]"
    else
      s += "\"next\":[\n"
      i = 1
      for id in @next
        s += indent + "\"#{id}\""
        if i == Object.keys(@next).length
          s += "\n"
        else
          s += ",\n"
        i += 1
      s += indent + "]"
    s

  error_message_to_s : ->
    "\"error_message\":\"#{@error_message}\""

  options_to_s : (indent=INDENT)->
    s = ""
    if Object.keys(@options).length == 0
      s += "\"options\":[]"
    else
      s += "\"options\":[\n"
      i = 1
      for option in @options
        s += indent + "\"#{option}\""
        if i == Object.keys(@options).length
          s += "\n"
        else
          s += ",\n"
        i += 1
      s += indent +  "]"
    s

  tags_to_s : (indent=INDENT)->
    s = ""
    if Object.keys(@tags).length == 0
      s += "\"tags\":[]"
    else
      s += "\"tags\":[\n"
      i = 1
      for tag in @tags
        s += indent + "\"#{tag}\""
        if i == Object.keys(@tags).length
          s += "\n"
        else
          s += ",\n"
        i += 1
      s += indent + "]"
    s

  value_to_s : ->
    "\"value\":\"#{@value}\""

  id_to_s : ->
    "\"id\":\"#{@id}\""

class Output
  id: ""
  title: "";
  type: ""
  options: []
  default_value: ""

  constructor: (id, type = "string")->
    @id = id
    @title = ""
    @type = type
    @options = []
    @default_value = null

  @from_hash : (hash) ->
    output = new Output(hash["id"])
    output.title = hash["title"]
    output.type = hash["type"]
    output.options = hash["options"]
    output.default_value = hash["default_value"]
    output

  to_s : (indent=INDENT) ->
    s = "\"#{@id}\":{\n"
    s += indent + "\"id\":\"#{@id}\",\n"
    s += indent + "\"type\":\"#{@type}\",\n"
    s += indent + "\"title\":\"#{@title}\",\n"
    s += indent + "\"default_value\":\"#{@default_value}\",\n"
    if Object.keys(@options).length == 0
      s += indent + "\"options\":[]\n"
    else
      s += indent + "\"options\":[\n"
      i = 1
      for o in @options
        s += indent + INDENT + "\"#{o}\""
        if i == Object.keys(@options).length
          s += "\n"
        else
          s += ",\n"
        i += 1
      s += indent + INDENT+ "]\n"
    s += indent + "}"
    s

############### 以下为 测试 ################3
test = ->
  console.log("test....")
  robot = new Robot("test")

  step1 = new Step(ACTION_VISIT)
  step1.options.push("aa")
  step1.options.push("aa")
  step2 = new Step(ACTION_EXTRACT)
  step3 = new Step(ACTION_CLICK)
  step4 = new Step(ACTION_FLUSH)
  step1.next.push( step2.id )
  step2.next.push( step3.id )
  step3.next.push( step4.id )
  robot.steps[step1.id] = step1
  robot.steps[step2.id] = step2
  robot.steps[step3.id] = step3
  robot.steps[step4.id] = step4

  output = new Output("test")
  output.options.push("bbb")
  output.options.push("bbb")
  robot.outputs[output.id] = output
  robot.first_step = step1.id
  s = robot.to_s()
  console.log( s )
  console.log( JSON.parse(s))
  console.log(JSON.stringify(JSON.parse(s)))
  robot2 = Robot.from_json_string(s)
  s2 = robot2.to_s()
  console.log(s2)
  console.log(JSON.stringify(JSON.parse(s2)))
  if s == s2
    console.log("equal.")

test2 = ->
  # 测试 add_step_before add_step_after remove_step
  robot = new Robot("test")

  step1 = new Step(ACTION_VISIT)
  step1.options.push("aa")
  step1.options.push("aa")
  step2 = new Step(ACTION_EXTRACT)
  step3 = new Step(ACTION_CLICK)
  step4 = new Step(ACTION_FLUSH)
  step1.next.push( step2.id )
  step2.next.push( step3.id )
  step3.next.push( step4.id )
  robot.steps[step1.id] = step1
  robot.steps[step2.id] = step2
  robot.steps[step3.id] = step3
  robot.steps[step4.id] = step4
  robot.first_step = step1.id

  step = new Step(ACTION_FLUSH)
  console.log(step.id)
  console.log(step1.id)
#  robot.add_step_before(step, step1)
#  console.log(robot.to_s())
#  robot.remove_step(step)
#  console.log(robot.to_s())
#  robot.add_step_after(step,step1)
#  console.log(robot.to_s())
#  robot.remove_step(step)
#  console.log(robot.to_s())
#  robot.add_step_before(step, step4)
#  console.log(robot.to_s())
#  robot.remove_step(step)
#  console.log(robot.to_s())
  robot.add_step_after(step, step4)
  console.log(robot.to_s())
  robot.remove_step(step)
  console.log(robot.to_s())



namespace = (target, name, block) ->
  [target, name, block] = [(if typeof exports isnt 'undefined' then exports else window), arguments...] if arguments.length < 3
  top = target
  target = target[item] or= {} for item in name.split '.'
  block target, top

namespace "ym.rpa", (exports) ->
  exports.Robot = Robot
  exports.Step = Step
  exports.Output = Output
  exports.ACTION_VISIT = ACTION_VISIT
  exports.ACTION_EXTRACT = ACTION_EXTRACT
  exports.ACTION_CLICK = ACTION_CLICK
  exports.ACTION_FLUSH = ACTION_FLUSH
  exports.ACTION_NOTHING = ACTION_NOTHING
  exports.test = test
  #exports.test2 = test2

