module Intent
  class Scope < Struct.new(
      :node,
      :children
    )

    def type
      node.type
    end

    def first_line
      node.loc.expression.first_line
    end

    def last_line
      node.loc.expression.last_line
    end

    def should_space?
      children.count >= 2
    end

  end
end