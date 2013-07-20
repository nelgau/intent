module Intent
  class Slicer
    attr_reader :source

    def initialize(source)
      @source = source
      @root_node = Parser::CurrentRuby.parse(source)
      @transformer = Transformer.new(source)

      construct_scopes
      index_scopes
    end

    def slice(line_numbers)
      terminals = terminal_scopes_at_lines(line_numbers)
      pruned_root = prune_tree(@root_scope, terminals)
      add_scope_to_output(pruned_root)
      @transformer.output
    end

    private

    def construct_scopes
      @root_scope = scope_for_node(@root_node)
    end

    def scope_for_node(node)
      scope = Scope.new(node, [])
      case node.type
      when *Parser::STRUCTURAL_TYPES 
        node.children.map do |c|
          scope.children << scope_for_node(c) if c
        end
      end
      scope
    end

    def index_scopes
      ranges = {}
      index_range_for_scope(ranges, @root_scope)
      @scope_tree = SegmentTree.new(ranges)
    end

    def index_range_for_scope(ranges, scope)
      scope.children.each { |s| index_range_for_scope(ranges, s) }
      case scope.node.type
      when *Parser::STRUCTURAL_TYPES 
      else
        range = scope.node.loc.expression
        ranges[(range.first_line..range.last_line)] = scope
      end
    end

    def terminal_scopes_at_lines(lines)
      scopes = Set.new
      lines.each do |ln|
        segment = @scope_tree.find(ln)
        scopes << segment.value if segment
      end
      scopes
    end

    def prune_tree(root_scope, active)
      pruned_children = []
      root_scope.children.each do |c|
        if Parser::STRUCTURAL_TYPES .include?(c.type) || active.include?(c)
          pruned_children << prune_tree(c, active)
        end
      end
      Scope.new(root_scope.node, pruned_children)
    end

    def add_scope_to_output(scope)
      case scope.node.type
      when *Parser::STRUCTURAL_TYPES 
        @transformer.emit_structural(scope) do
          scope.children.each { |c| add_scope_to_output(c) }
        end
      else
        @transformer.emit_terminal(scope)
      end
    end

  end
end
