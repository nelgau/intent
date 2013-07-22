module Intent
  class Frame
    attr_reader :file
    attr_reader :klass
    attr_reader :id

    attr_reader :first_line
    attr_reader :last_line

    attr_reader :subframes
    attr_reader :events  
    attr_reader :annotations

    def initialize(file, line, klass, id)
      @file = file
      @klass = klass
      @id = id

      @first_line = line
      @last_line = line

      @subframes = []
      @events = []
      @annotations = []
    end

    def walk_in_order(&block)
      block.call(self)
      subframes.each { |sfr| sfr.walk_in_order(&block) }
    end

    def add_line(line)
      @first_line = line if line < @first_line
      @last_line  = line if line > @last_line
    end

    def add_subframe(frame)
      @subframes << frame
    end

    def add_event(event)
      @events << event
    end

    def add_annotation(annotation)
      @annotations << annotation
    end

  end
end