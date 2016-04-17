module RgGen
  module Configuration
    class Item < InputBase::Item
      include RaiseError

      def configuration
        @owner
      end
    end
  end
end
