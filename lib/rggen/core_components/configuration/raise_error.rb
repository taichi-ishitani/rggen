module RgGen
  module Configuration
    module RaiseError
      private

      def error(message = nil)
        raise RgGen::ConfigurationError, message
      end
    end
  end
end
