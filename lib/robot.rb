require 'securerandom'
# robotic processing automation
module RPA


  class Robot
    attr_accessor :first_step, :steps, :outputs, :name, :id, :deleted, :type

    def initialize(name)
      @name = name
      @id = SecureRandom.uuid
      @deleted = false
      @steps = []
      @outputs = []
    end

  end

  class Step
    attr_accessor :id, :action,  :next
    attr_accessor :options,:error_message

    def initialize(action)
      @id = SecureRandom.uuid
      @options = []
      @action = action
      @next = []
    end
  end

  class Visit < Step
    attr_accessor :title, :tags, :value

    def initialize(value)
      @value = value
      @tags = []
      @title = ""
      super(:VISIT)
    end

  end



  if __FILE__==$0
    puts :VISIT.to_s


  end

end