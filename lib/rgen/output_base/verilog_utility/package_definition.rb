module RGen
  module OutputBase
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
          import_packages << ImportedPackage.new(name, items)
        end

        def include_file(name)
          include_files << "`include #{name.to_s.quote}"
        end

        def to_code
          bodies.unshift(include_fiels_code ) unless @include_files.nil?
          bodies.unshift(import_packges_code) unless @import_packages.nil?
          super
        end

        private

        def header_code
          "package #{@name};"
        end

        def footer_code
          :endpackage
        end

        def import_packages
          @import_packages ||= []
        end

        def include_files
          @include_files ||= []
        end

        def import_packges_code
          lambda do |code|
            import_packages.each do |package|
              code << package << nl
            end
          end
        end

        def include_fiels_code
          lambda do |code|
            include_files.each do |file|
              code << file << nl
            end
          end
        end
      end
    end
  end
end
