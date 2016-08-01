require 'securerandom'
require 'json'
# robotic processing automation
module RPA
  ACTIONS = [:VISIT, :CLICK, :EXTRACT, :FLUSH , :NOTHING]
  ACTION_VISIT = :VISIT
  ACTION_CLICK = :CLICK
  ACTION_EXTRACT = :EXTRACT
  ACTION_FLUSH = :FLUSH
  ACTION_NOTHING = :NOTHING
  INDENT = "    "

  class Robot
    attr_accessor :first_step, :steps, :outputs, :name, :id, :deleted

    def initialize(name)
      @steps = {}
      @outputs = {}
      @name = name
      @id = SecureRandom.uuid
      @deleted = false
    end

    def to_s(indent=INDENT)
      s = "{\n"
      s += indent + first_step_to_s + ",\n" if @first_step
      s += indent + steps_to_s(indent + INDENT) + ",\n"
      s += indent + outputs_to_s(indent + INDENT) + ",\n"
      s += indent + name_to_s + ",\n"
      s += indent + id_to_s + ",\n"
      s += indent + deleted_to_s + "\n" # <--- 最后一个没有逗号
      s += "}\n"
    end

    def to_one_line
      s = to_s
      s = s.gsub(/\n/,'')
      s
    end

    def self.from_json_string(json_string)
      robot = Robot.new("")
      jo = JSON(json_string)
      robot.first_step = jo["first_step"]
      jo["steps"].each do |id, step|
        robot.steps[id] = Step.from_hash(step)
      end
      jo["outputs"].each do |id, output|
        robot.outputs[id] = Output.from_hash(output)
      end
      robot.name = jo["name"]
      robot.id = jo["id"]
      robot.deleted = (jo["deleted"] == "true")?true : false
      robot
    end

    private
    def first_step_to_s
      %Q("first_step":"#{@first_step}")
    end

    def steps_to_s(indent=INDENT)
      s = ""
      if @steps.length == 0
        s += %Q("steps":{})
      else
        s += %Q("steps":{\n)
        i = 1
        @steps.each do |id,step|
          s += indent + step.to_s(indent + INDENT)
          if i != @steps.length
            s += ",\n"
          else
            s += "\n"
          end
          i += 1
        end
        s += indent +  "}"
      end
      s
    end

    def outputs_to_s(indent=INDENT)
      s = ""
      if @outputs.length == 0
        s += %Q("outputs":{})
      else
        s += %Q("outputs":{\n)
        i = 1
        @outputs.each do |id,output|
          s += indent + output.to_s(indent+ INDENT)
          if i == @outputs.length
            s += "\n"
          else
            s += ",\n"
          end
          i += 1
        end
        s += indent + "}"
      end
      s
    end

    def name_to_s
      %Q("name":"#{@name}")
    end

    def id_to_s
      %Q("id":"#{@id}")
    end

    def deleted_to_s
      %Q("deleted":"#{@deleted}")
    end

  end

  class Step
    attr_accessor :id, :action, :title, :field, :value, :tags, :next
    attr_accessor :options, :error_message

    def initialize(action)
      @id = SecureRandom.uuid
      @action = (ACTIONS.include? action) ? action : ACTION_VISIT
      @title = ""
      @field = ""
      @value = ""
      @tags = []
      @next = []
      @options = []
      @error_message = ""
    end

    def self.from_hash(hash)
      step = Step.new(hash["action"].to_sym)
      step.id = hash["id"]
      step.title = hash["title"]
      step.field = hash["field"]
      step.value = hash["value"]
      step.tags = hash["tags"]
      step.next = hash["next"]
      step.options = hash["options"]
      step.error_message = hash["error_message"]
      step
    end

    # step只是一部分
    def to_s(indent=INDENT)
      s = %Q("#{@id}":{\n)
      s += indent + id_to_s + ",\n"
      s += indent + action_to_s + ",\n"
      s += indent + title_to_s + ",\n"
      s += indent + field_to_s + ",\n"
      s += indent + value_to_s + ",\n"
      s += indent + tags_to_s(indent + INDENT) + ",\n"
      s += indent + next_to_s(indent + INDENT) + ",\n"
      s += indent + options_to_s(indent + INDENT) + ",\n"
      s += indent + error_message_to_s + "\n"
      s += indent + "}"
      s
    end

    def action_to_s
      %Q("action":"#{@action}")
    end

    def field_to_s
      %Q("field":"#{@fie}")
    end

    def title_to_s
      %Q("title":"#{@title}")
    end

    def next_to_s(indent=INDENT)
      s = ""
      if @next.length == 0
        s += %Q("next":[])
      else
        s += %Q("next":[\n)
        i = 1
        @next.each do |id|
          s += indent + %Q("#{id}")
          if i == @next.length
            s += "\n"
          else
            s += ",\n"
          end
          i += 1
        end
        s += indent +  "]"
      end
      s
    end

    def error_message_to_s
      %Q("error_message":"#{@error_message}")
    end

    def options_to_s(indent=INDENT)
      s = ""
      if @options.length == 0
        s += %Q("options":[])
      else
        s += %Q("options":[\n)
        i = 1
        @options.each do |option|
          s += indent + %Q("#{option}")
          if i == @options.length
            s += "\n"
          else
            s += ",\n"
          end
          i += 1
        end
        s += indent +  "]"
      end
      s
    end

    def tags_to_s(indent=INDENT)
      s = ""
      if @tags.length == 0
        s += %Q("tags":[])
      else
        s += %Q("tags":[\n)
        i = 1
        @tags.each do |tag|
          s += indent + %Q("#{tag}")
          if i == @tags.length
            s += "\n"
          else
            s += ",\n"
          end
          i += 1
        end
        s += indent + "]"
      end
      s
    end

    def value_to_s
      %Q("value":"#{@value}")
    end
    def id_to_s
      %Q("id":"#{@id}")
    end
  end


  class Output
    attr_accessor :id, :title, :type, :options, :default_value

    def initialize(id, type=:string)
      @id = id
      @title = ""
      @type = type
      @options = []
      @default_value = ""
    end

    def self.from_hash(hash)
      output = Output.new(hash["id"])
      output.title = hash["title"]
      output.type = hash["type"].to_sym
      output.options = hash["options"]
      output.default_value = hash["default_value"]
      output
    end

    def to_s(indent=INDENT)
      s = %Q("#{id}":{\n)
      s += indent + %Q("id":"#{@id}",\n)
      s += indent + %Q("type":"#{@type}",\n)
      s += indent + %Q("title":"#{@title}",\n)
      s += indent + %Q("default_value":"#{@default_value}",\n)
      if @options.length == 0
        s += indent + %Q("options":[]\n)
      else
        s += indent + %Q("options":[\n)
        i = 1
        @options.each do |o|
          s += indent + INDENT + %Q("#{o}")
          if i == @options.length
            s += "\n"
          else
            s += ",\n"
          end
          i += 1
        end
        s += indent + INDENT+ "]\n"
      end
      s += indent + "}"
      s
    end

  end

############################################ 以下为test #################
  def self.test
    robot = Robot.new("test")
    puts robot.to_s
    puts JSON(robot.to_s)

    step1 = Step.new(ACTION_VISIT)
    step1.options << "bbbb"
    step1.options << "bbbb"
    step2 = Step.new(ACTION_EXTRACT)
    step3 = Step.new(ACTION_CLICK)
    step4 = Step.new(ACTION_FLUSH)
    steps = [step1, step2, step3, step4]
    step1.next << step2.id
    step2.next << step3.id
    step3.next << step4.id
    robot.steps[step1.id] = step1
    robot.steps[step2.id] = step2
    robot.steps[step3.id] = step3
    robot.steps[step4.id] = step4

    output = Output.new("test")
    output.options << "aaaa"
    output.options << "aaaa"
    robot.outputs[output.id] = output
    robot.first_step = step1.id
    puts robot.to_s
    puts JSON(robot.to_s)

    robot2 = Robot.from_json_string(robot.to_s)

    if robot.to_s == robot2.to_s
      puts "equal."
    end

    s = robot2.to_one_line
    p s

  end

  if __FILE__==$0
    test

    time = Time.new

    puts time.to_s
    puts time.ctime
    puts time.localtime
    puts time.strftime("%Y-%m-%d %H:%M:%S")
    name = "test@" + time.strftime("%Y-%m-%d_%H:%M:%S")
    puts name
  end

end