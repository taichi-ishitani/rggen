module RGen
  module Commands
    extend Forwardable

    def generator
      @generator  ||= RGen::Generator.new
    end

    [
      [:component_registry, :component_registry],
      [:register_item     , :item              ],
      [:enable            , :enable            ],
      [:register_loader   , :register_loader   ]
    ].each do |method_name, alias_name|
      def_delegator('generator.builder', method_name, alias_name)
    end
  end

  extend Commands
end
