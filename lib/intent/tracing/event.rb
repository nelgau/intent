module Intent
  class Event
    attr_reader :event
    attr_reader :file
    attr_reader :line
    attr_reader :id
    attr_reader :annotations

    def initialize(event, file, line, id)
      @event = event
      @file = file
      @line = line
      @id = id
      @annotations = []
    end

    def inspect
      id_name = id ? "'#{id}'" : "no_id"
      "#<#{self.class.name} #{event}:#{file}:#{line} #{id_name}>"
    end

    def to_s
      self.inspect
    end      
  end
end