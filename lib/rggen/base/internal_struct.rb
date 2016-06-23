module RgGen
  module Base
    module InternalStruct
      private

      def internal_structs
        @internal_structs ||= {}
      end

      def define_struct(struct_name, members, &body)
        return if internal_structs.key?(struct_name)
        internal_structs[struct_name] = Struct.new(*members, &body)
        define_method(struct_name) do
          self.class.send(:internal_structs)[struct_name]
        end
        private(struct_name)
      end

      def inherited(subclass)
        super(subclass)
        return unless instance_variable_defined?(:@internal_structs)
        subclass.instance_variable_set(
          :@internal_structs, Hash[@internal_structs]
        )
      end
    end
  end
end
