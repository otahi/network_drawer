require 'network_drawer'
require 'ostruct'

require 'gviz'

module NetworkDrawer
  module Element
    # Replesent of element
    class Element < OpenStruct
      DEFAULT_STYLE = {}

      class << self
        def generate_id
          @ids ? @ids += 1 : @ids = 0
        end
      end

      def initialize(initial_values = {}, style = {})
        super(initial_values)
        self.id = self.class.generate_id
        @default_style = DEFAULT_STYLE
        @style = style
      end

      def to_hash
        hash = {}
        self.each_pair do |k, v|
          hash.merge!(k.to_sym => v) unless k.to_sym == name
        end
        hash
      end

      private

      def style(type)
        # TODO: select multiple types
        type = type.to_sym if type
        style = @style ? @style[type] : {}
        style ? @default_style.merge(style) : @default_style
      end
    end
  end
end
