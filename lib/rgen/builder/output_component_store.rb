module RGen
  module Builder
    class OutputComponentStore < ComponentStore
      attr_setter :output_directory

      def build_factory
        f                   = super
        f.output_directory  = @output_directory
        f
      end
    end
  end
end
