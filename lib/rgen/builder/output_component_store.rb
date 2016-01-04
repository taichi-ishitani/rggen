module RGen
  module Builder
    class OutputComponentStore < ComponentStore
      attr_setter :output_directory

      def build_factory
        super.tap do |f|
          f.output_directory  = @output_directory
        end
      end
    end
  end
end
