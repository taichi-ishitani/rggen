module RgGen
  module RAL
    class Component < OutputBase::Component
      def sub_model_declarations
        @sub_model_declarations ||= []
      end
    end
  end
end
