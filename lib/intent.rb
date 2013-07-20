require 'parser'
require 'parser/current'
require 'segment_tree'
require 'pathname'

require 'intent/tracing'
require 'intent/parsing'
require 'intent/operations'

module Intent

  def self.slice(options={}, &block)
    Slice.run(options, &block)
  end

end