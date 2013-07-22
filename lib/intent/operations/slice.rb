module Intent
  module Slice

    DOMAINS = {
      :source => ['.slice',      lambda { Pathname.pwd }],
      :ruby   => ['.slice/ruby', lambda { ruby_home_path }],
      :gems   => ['.slice/gems', lambda { gems_home_path }]
    }

    INTERNAL_INGORE = [
      '(irb)',
      '<internal:prelude>'
    ]

    def self.run(options={}, &block)
      prepare

      puts "[slice] Running...".green
      root_frame = Recorder.run!(&block)

      puts "[slice] Analyzing trace...".green
      trace_map = map_execution(root_frame)

      puts "[slice] Slicing files...".green
      slice_source_files(trace_map, options)

      puts "[slice] Done. :)".green

      # Because we reasonably expect this to run in IRB
      nil
    rescue => e
      puts "[slice] Error: #{e}".red
      raise e
    end

    private

    class << self

      def prepare
        DOMAINS.each_pair do |key, value|
          if (domain_path = value.second.call)
            slice_path = Pathname.pwd + value.first
            FileUtils.rm_rf(slice_path) rescue nil
            FileUtils.mkdir_p(slice_path)
          end
        end
      end

      def map_execution(root_frame)
        trace_map = {}
        root_frame.walk_in_order do |fr|
          (trace_map[fr.file] ||= Set.new) << fr.first_line
        end
        trace_map
      end

      def slice_source_files(trace_map, options)
        include_domains = [:source, options[:include]].flatten.compact

        trace_map.each_pair do |file, lines|
          next unless should_slice?(file)
          type, display_path, sliced_path = determine_route(file)
          next unless include_domains.include?(type)

          tag = tag_for_type(type)
          puts "  -> #{tag}#{display_path}"

          source = File.read(file)
          slicer = Slicer.new(source)
          sliced_source = slicer.slice(lines)

          File.write(sliced_path, sliced_source)
        end
      end

      def should_slice?(file)
        !INTERNAL_INGORE.include?(file)
      end

      def determine_route(file)
        file_path = Pathname.new(file)
        file_path = pwd_path + file_path if file_path.relative?

        domains = []
        DOMAINS.each_pair do |key, value|
          if (domain_path = value.last.call)
            domains << {
              :type => key,
              :slice_path => Pathname.pwd + value.first,
              :relative => file_path.relative_path_from(domain_path)
            }
          end
        end

        domains.sort_by! { |d| d[:relative].to_s.length }
        likely_domain = domains.first

        type = likely_domain[:type]
        slice_path = likely_domain[:slice_path]
        relative = likely_domain[:relative].to_s

        transformed_name = relative.gsub(/\//, '__')
        sliced_file_path = "#{slice_path}/#{transformed_name}"

        [type, relative, sliced_file_path]
      end
    
      def ruby_home_path
        return unless ENV['MY_RUBY_HOME']
        Pathname.new(ENV['MY_RUBY_HOME']).realpath
      end

      def gems_home_path
        return unless ENV['GEM_HOME']
        Pathname.new(ENV['GEM_HOME']).realpath
      end

      def tag_for_type(type)
        case type
        when :gems then '[gems] '.blue      
        when :ruby then '[ruby] '.red        
        else ''
        end
      end

    end

  end
end