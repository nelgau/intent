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
      execute_block(&block)
      trace_with_proc(nil)
      @frames[0]
    end

    def add_annotation(annotation)
      frame = current_frame
      frame.add_annotation(annotation) if frame
    end

    private

    def execute_block(&block)
      block.call
    rescue => e
      puts "[tracing] Caught exception with tracing: #{e}".red
    end

    def trace_func(event, file, line, id, binding, klass, *)
      # Don't trace the recorder
      return if file == __FILE__

      @frames[0] ||= Frame.new(file, line, klass, id)

      push_frame Frame.new(file, line, klass, id) if event == 'call'
      current_frame.add_line(line)

      if @trace_events
        event = Event.new(event, file, line, id)
        current_frame.add_event(event)
      end

      pop_frame if event == 'return'
    rescue => e
      puts "[tracing] Caught exception in trace proc: #{e}".red
      exit!
    end

    def push_frame(frame)
      current_frame.add_subframe(frame)
      @frames << frame
    end

    def pop_frame
      @frames.pop
    end

    def current_frame
      @frames.last
    end

    def trace_with_proc(proc)
      Thread.current.set_trace_func(proc)
    end

  end
end