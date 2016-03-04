module RGen
  module RAL
    class Item < OutputBase::Item
      use_verilog_utility

      private

      def model_declaration(model_class, name, attributes = {})
        create_declaration(
          :variable,
          attributes.merge(data_type: model_class, name: name, random: true)
        )
      end
    end
  end
end
