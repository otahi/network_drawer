require 'network_drawer'

module NetworkDrawer
  module Element
    # Replesent of connection
    class Connection < Element
      DEFAULT_STYLE = {}

      def initialize(initial_values = {}, style = {})
        super
        @default_style = DEFAULT_STYLE
      end

      def to_code
        style = style(self.type).dup
        style.merge!(self.to_hash)
        cid = "#{self.from}_#{self.to}_#{self.seq}".gsub('/', '').to_sym
        "edge(:\"#{cid}\", #{style})\n"
      end
    end
  end
end
