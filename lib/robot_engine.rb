require File.dirname(__FILE__) + "/robot"
require File.dirname(__FILE__) + "/nokogiri_parse"
require File.dirname(__FILE__) + "/../app/models/output"

module RPA
  class RobotEngine
    attr_accessor :parse_engine, :doc,:robot, :step_id, :url
    attr_accessor :is_end, :pre_step_id
    attr_accessor :outputs

    # @param [NokogiriParse] parse_engine
    # @param [Robot] robot
    def initialize(parse_engine, robot)
      @parse_engine = parse_engine
      @robot = robot
      @step_id = robot.first_step
      @is_end = false
    end

    def run
      if @step_id.length != 32
        raise "step_id is not a uuid string."
      end

      while @is_end == false
        next_step
      end

    end

    def next_step
      step = @robot.steps[@step_id]
      action = step.action
      case action
        when RPA::ACTION_VISIT
          @url = step.value
          @doc = @parse_engine.get_doc(url)
        when RPA::ACTION_CLICK
          ele_xpath = step.tags[0]
          @doc = @parse_engine.click(@url, ele_xpath)
        when RPA::ACTION_EXTRACT
          @outputs = @robot.outputs
          output = @outputs[step.field]
          xpath = step.tags[0]
          result = @parse_engine.extract(@url, xpath)
          if output.options.length > 0
            # clean result with option
          end
          output.value = result
        when RPA::ACTION_FLUSH
          #save outputs
          flush
        else
          raise("action type is wrong.")
      end
      @pre_step_id = @step_id
      if step.next.length > 0
        @step_id = step.next[0]
      else
        @step_id = nil
        @is_end = true
      end

    end

    def flush
      output_json = "{"
      i = 1
      @outputs.each do |output|
        output_json += %Q("#{output.id}":"#{output.value}")
        if i != @outputs.length
          output_json += ","
        end
        i += 1
      end
      output_json += "}"
      output_result = OuputResult.new
      output_result.robot_id = @robot.id
      output_result.output_result = output_json
      output_result.save
    end

  end



  if __FILE__==$0
    robot = Robot.new("test")
    puts robot.to_s


  end
end