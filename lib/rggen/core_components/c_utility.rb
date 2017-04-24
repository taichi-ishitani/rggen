module RgGen
  module CUtility
    include CodeUtility

    private

    def variable_declaration(attributes)
      VariableDeclaration.new(attributes)
    end

    def struct_definition(type_name, &body)
      DataStructureDefinition.new(:struct, type_name, &body).to_code
    end
  end
end
