module RgGen
  module Configuration
    module RaiseError
      private

      def error(message = nil)
        fail RgGen::ConfigurationError, message
      end
    end
  end
end
