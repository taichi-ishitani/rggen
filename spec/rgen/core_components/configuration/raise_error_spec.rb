require_relative  '../../../spec_helper'

module RGen::Configuration
  describe RaiseError do
    describe "#error" do
      let(:message) do
        "some configuration error"
      end

      it "入力されたメッセージで、RGen::ConfigurationErrorを発生さえる" do
        m = message
        i = Class.new {
          include RaiseError
          define_method(:test) do
            error m
          end
        }.new

        expect{i.test}.to raise_configuration_error message
      end
    end
  end
end
