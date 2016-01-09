module RGen
  module InputBase
    module RegxpPatterns
      BIN_REGEXP  = /0b(?:[01][01_]*)?[01]/i.freeze
      OCT_REGEXP  = /0o(?:[0-7][0-7_]*)?[0-7]/i.freeze
      DEC_REGEXP  = /(?:[1-9][\d_]*)?\d/.freeze
      HEX_REGEXP  = /0x(?:\h[\h_]*)?\h/i.freeze

      UNSIGNED_NUMBER_REGEXP  = (
        /\b/ + (BIN_REGEXP | OCT_REGEXP | DEC_REGEXP | HEX_REGEXP) + /\b/
      ).freeze
      VARIABLE_NAME_REGEXP    = /\b[a-z_][a-z0-9_]*\b/i.freeze

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
    end
  end
end
