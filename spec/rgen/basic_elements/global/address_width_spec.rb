require_relative '../spec_helper'

describe 'address_width/configuration' do
  include_context 'configuration common'

  before(:all) do
    RGen.enable(:global, :address_width)
    @factory  = build_configuration_factory
  end

  after(:all) do
    clear_enabled_items
  end

  let(:configuration) do
    @factory.create(configuration_file)
  end

  describe "#address_width" do
    context "ロード結果のHashに:address_widthが含まれないとき" do
      before do
        ConfigurationDummyLoader.load_data({})
      end

      it "デフォルト値(32)を返す" do
        c = @factory.create(configuration_file)
        expect(c).to match_address_width(32)
      end
    end

    context "ロード結果のHashに:address_widthが含まれていて、正の整数に変換できるとき" do
      let(:load_data) do
        [1, 8.0, "16"]
      end

      it "変換結果を返す" do
        load_data.each do |data|
          w = Integer(data)
          ConfigurationDummyLoader.load_data({address_width: w})

          c = @factory.create(configuration_file)
          expect(c).to match_address_width(w)
        end
      end
    end
  end
end
