module RgGen
  module CUtility
    include CodeUtility

    def create_blank_file(path)
      SourceFile.new(path)
    end

    private

    def variable_declaration(attributes)
      VariableDeclaration.new(attributes)
    end

    def struct_definition(type_name, &body)
      DataStructureDefinition.new(:struct, type_name, &body).to_code
    end
  end
end
