module Intent
  class Recorder
    attr_reader :options
    attr_reader :filter

    def self.run!(options={}, &block)
      Recorder.new(options).run(&block)
    end

    def initialize(options={})
      @options = options
      @filter = Set.new
      @trace_proc = method(:trace_func).to_proc
    end

    def run(&block)
      @trace = []
      trace_with_proc(@trace_proc)
      yield if block_given?
      trace_with_proc(nil)
      @trace
    end

    def trace_func(event, file, line, id, binding, klass, *)
      @trace << Event.new(event, file, line, id) unless file == __FILE__
    end

    def trace_with_proc(proc)
      Thread.current.set_trace_func(proc)
    end

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

    class Annotation
    end

  end
end