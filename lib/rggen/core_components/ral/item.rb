module RgGen
  module RAL
    class Item < OutputBase::Item
      use_verilog_utility

      private

      def model_declaration(model_class, name, attributes = {})
        owner.parent.sub_model_declarations << create_declaration(
          :variable,
          attributes.merge(data_type: model_class, name: name, random: true)
        )
      end
    end
  end
end
