module RgGen
  module VerilogUtility
    class PackageDefinition < StructureDefinition
      ImportedPackage = Struct.new(:name, :items) do
        def to_s
          "import #{import_items.join(', ')};"
        end

        def import_items
          (((items.nil? || items.empty?) && [:*]) || items).map do |item|
            "#{name}::#{item}"
          end
        end
      end

      def import_package(name, items = nil)
        @import_packages ||= []
        @import_packages << ImportedPackage.new(name, items)
      end

      def include_file(name)
        @include_files ||= []
        @include_files << "`include #{name.to_s.quote}"
      end

      private

      def header_code
        "package #{@name};"
      end

      def body_code_blocks
        blocks = []
        @import_packages && (blocks << import_packges_code)
        @include_files && (blocks << include_files_code)
        blocks.concat(super)
        blocks
      end

      def footer_code
        :endpackage
      end

      def import_packges_code
        lambda do |code|
          @import_packages.each { |package| code << package << nl }
        end
      end

      def include_files_code
        lambda do |code|
          @include_files.each { |file| code << file << nl }
        end
      end
    end
  end
end
