module Intent
  class Recorder
    attr_reader :options
    attr_reader :filter

    def self.run!(options={}, &block)
      Recorder.new(options).run(&block)
    end

    def initialize(options={})
      @options = options
      @trace_events = !!options[:trace_events]

      @trace_proc = method(:trace_func).to_proc
    end

    def run(&block)
      @frames = []
      trace_with_proc(@trace_proc)
      yield if block_given?
      trace_with_proc(nil)
      @frames[0]
    end

    def trace_func(event, file, line, id, binding, klass, *)
      # Don't trace the recorder
      return if file == __FILE__

      @frames[0] ||= Frame.new(file, line, klass, id)
      this_frame = @frames.last

      if event == 'call'
        new_frame = Frame.new(file, line, klass, id)
        @frames << new_frame
        this_frame.add_subframe(new_frame)
        this_frame = new_frame
      end

      this_frame.add_line(line)

      if @trace_events
        event = Event.new(event, file, line, id)
        this_frame.add_event(event)
      end

      if event == 'return'
        @frames.pop
      end
    rescue => e
      puts "[tracing] Caught exception #{e}".red
      exit!
    end

    def trace_with_proc(proc)
      Thread.current.set_trace_func(proc)
    end
  end
end