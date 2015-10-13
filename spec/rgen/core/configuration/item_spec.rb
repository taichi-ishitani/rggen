require_relative  '../../../spec_helper'

module RGen::Configuration
  describe Item do
    let(:configuration) do
      get_component_class(:configuration, 0).new
    end

    let(:item_base) do
      get_item_base(:configuration, 0)
    end

    describe "#error" do
      let(:message) do
        "some configuration error"
      end

      it "入力されたメッセージで、RGen::ConfigurationErrorを発生さえる" do
        m = message
        i = Class.new(item_base) {
          validate do
            error m
          end
        }.new(configuration)

        expect{i.validate}.to raise_configuration_error message
      end
    end
  end
end
