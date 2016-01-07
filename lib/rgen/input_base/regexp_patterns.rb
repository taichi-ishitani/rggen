module RGen
  module InputBase
    module RegxpPatterns
      BIN_REGEXP  = /0b(?:[01]|(?:[01][01_]*[01]))/i.freeze
      OCT_REGEXP  = /0o(?:[0-7]|(?:[0-7][0-7_]*[0-7]))/i.freeze
      DEC_REGEXP  = /\d|[1-9][0-9_]*[0-9]/.freeze
      HEX_REGEXP  = /0x(?:\h|\h[\h_]*\h)/i

      UNSIGNED_NUMBER_REGEXP  = (
        BIN_REGEXP | OCT_REGEXP | DEC_REGEXP | HEX_REGEXP
      ).freeze
      VARIABLE_NAME_REGEXP    = /[a-z_][a-z0-9_]*/i.freeze
      BLANK_REGEXP            = /[ \t]*/.freeze

      def self.included(klass)
        klass.extend(self)
      end

      private

      def number
        UNSIGNED_NUMBER_REGEXP
      end

      def variable_name
        VARIABLE_NAME_REGEXP
      end

      def blank
        BLANK_REGEXP
      end

      def wrap_blank(pattern)
        blank + pattern + blank
      end
    end
  end
end
