module RgGen
  module RegisterMap
    class Loader < InputBase::Loader
      private

      def create_map(file)
        GenericMap.new(file).tap { |m| yield(m) if block_given? }
      end
    end
  end
end
