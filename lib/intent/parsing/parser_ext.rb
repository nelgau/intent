module Parser

  STRUCTURAL_TYPES = [
    :begin,
    :module,
    :class,
    :sclass
  ]

  module Source
    class Range
      alias_method :first_line, :line

      def last_line
        line, _ = @source_buffer.decompose_position(@end_pos)
        line
      end
    end
  end
  
end
