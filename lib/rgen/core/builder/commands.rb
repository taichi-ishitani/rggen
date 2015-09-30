module RGen::Builder
  module Commands
    extend Forwardable

    def builder
      @builder  ||= Builder.new
    end

    [
      [:component_store  , :component_store],
      [:define_value_item, :value_item     ],
      [:define_list_item , :list_item      ],
      [:enable           , :enable         ],
      [:define_loader    , :loader         ]
    ].each do |method_name, alias_name|
      def_delegator(:builder, method_name)
      alias_method(alias_name, method_name) if method_name != alias_name
    end
  end
end
