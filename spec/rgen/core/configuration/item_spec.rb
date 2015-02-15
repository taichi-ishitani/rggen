require_relative  '../../../spec_helper'

module RGen::Configuration
  describe Item do
    let(:configuration) do
      Configuration.new
    end

    describe "#error" do
      let(:message) do
        "some configuration error"
      end

      it "入力されたメッセージで、RGen::ConfigurationErrorを発生さえる" do
        m = message
        i = Class.new(Item) {
          validate do
            error m
          end
        }.new(configuration)

        expect{i.validate}.to raise_configuration_error message
      end
    end
  end
end
