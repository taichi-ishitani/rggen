module RGen
  def self.builder
    @builder  ||= Builder::Builder.new
  end

  module Commands
    extend Forwardable

    [
      [:input_component_store , :input_component_store ],
      [:output_component_store, :output_component_store],
      [:define_simple_item    , :simple_item           ],
      [:define_list_item      , :list_item             ],
      [:enable                , :enable                ],
      [:define_loader         , :loader                ]
    ].each do |method_name, alias_name|
      def_delegator('RGen.builder', method_name)
      alias_method(alias_name, method_name) if method_name != alias_name
    end
  end
end

include RGen::Commands
