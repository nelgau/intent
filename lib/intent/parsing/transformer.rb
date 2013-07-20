module Intent
  class Transformer
    attr_reader :source
    attr_reader :source_lines

    attr_reader :lines

    def initialize(source)
      @source = source
      @source_lines = source.lines.to_a

      @lines = []
      @scope_stack = []
      @spacing_scopes = Set.new
    end

    def output
      lines.join
    end

    def reset
      lines.clear
    end

    def emit_structural(scope, &block)
      add_empty_line if should_space?
      @scope_stack << scope
      @spacing_scopes << scope if scope.should_space?

      case scope.type
      when :begin          
        yield
      when *(Parser::STRUCTURAL_TYPES - [:begin])
        lines << source_lines[scope.first_line - 1]
        yield
        lines << source_lines[scope.last_line - 1]
      end

      @scope_stack.pop
      @spacing_scopes.delete(scope)
      add_empty_line if should_space?        
    end

    def emit_terminal(scope)
      add_empty_line
      lines.concat(source_lines[scope.first_line - 1..scope.last_line - 1])
      add_empty_line
    end

    private

    def current_scope
      @scope_stack.last
    end

    def should_space?
      @spacing_scopes.include?(current_scope)
    end

    def add_empty_line
      lines << "\n" unless lines.last == "\n" || lines.empty?
    end

  end
end