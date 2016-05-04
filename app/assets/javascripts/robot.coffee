
# module public variable to be in exports
ACTION_VISIT = "VISIT"
ACTION_CLICK = "CLICK"
ACTION_EXTRACT = "EXTRACT"
ACTION_FLUSH = "FLUSH"

#module private variable
INDENT  = "    "
ACTIONS = ["VISIT", "CLICK", "EXTRACT", "FLUSH"]

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

  add_step : (step)->
    @steps[step.id] = step

  remove_step : (step) ->
    delete @steps[step.id]

  add_output : (output) ->
    @outputs[output.id] = output

  remove_output : (output) ->
    delete @outputs[output.id]

class Step
  id: ""
  action: ""
  title : ""
  value : ""
  tags : []
  next : []
  options : []
  error_message : ""

  @from_hash: (hash)->
    step = new Step(hash["action"])
    step.id = hash["id"]
    step.title = hash["title"]
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
    @title = ""
    @value = ""
    @tags = []
    @next = []
    @options = []
    @error_message = ""

  # step只是一部分
  to_s: (indent = INDENT) ->
    s = "\"#{@id}\":{\n"
    s += indent + @id_to_s() + ",\n"
    s += indent + @action_to_s() + ",\n"
    s += indent + @title_to_s() + ",\n"
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
    @default_value = ""

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
  steps = [step1, step2, step3, step4]
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

namespace = (target, name, block) ->
  [target, name, block] = [(if typeof exports isnt 'undefined' then exports else window), arguments...] if arguments.length < 3
  top = target
  target = target[item] or= {} for item in name.split '.'
  block target, top

namespace "ym.rpa", (exports) ->
  exports.Robot = Robot
  exports.Step = Step
  exports.Ouput = Output
  exports.ACTION_VISIT = ACTION_VISIT
  exports.ACTION_EXTRACT = ACTION_EXTRACT
  exports.ACTION_CLICK = ACTION_CLICK
  exports.ACTION_FLUSH = ACTION_FLUSH
  #exports.test = test

