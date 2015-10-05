require_relative '../spec_helper'

describe 'global/address_width' do
  include_context 'configuration common'

  before(:all) do
    RGen.enable(:global, :address_width)
    @factory  = build_configuration_factory
  end

  after(:all) do
    clear_enabled_items
  end

  describe "#address_width" do
    context "ロード結果のHashに:address_widthが含まれないとき" do
      it "デフォルト値(32)を返す" do
        ConfigurationDummyLoader.load_data({})
        c = @factory.create(configuration_file)
        expect(c).to match_address_width(32)
      end
    end

    context "ロード結果のHashに:address_widthが含まれていて、正の整数に変換できるとき" do
      let(:load_data) do
        [1, 8.0, "16", "0x20"]
      end

      it "変換結果を返す" do
        load_data.each do |data|
          ConfigurationDummyLoader.load_data({address_width: data})
          c = @factory.create(configuration_file)
          expect(c).to match_address_width(Integer(data))
        end
      end
    end
  end

  context "入力が整数に変換できなかったとき" do
    let(:load_data) do
      ["1.0", "foo", "0xGH", Object.new, []]
    end

    it "RGen::ConfigurationErrorを発生させる" do
      load_data.each do |data|
        ConfigurationDummyLoader.load_data({address_width: data})
        m = "invalid value for address width: #{data.inspect}"
        expect{@factory.create(configuration_file)}.to raise_configuration_error m
      end
    end
  end

  context "入力がゼロのとき" do
    it "RGen::ConfigurationErrorを発生させる" do
      ConfigurationDummyLoader.load_data({address_width: 0})
      m = "zero/negative address width is not allowed: 0"
      expect{@factory.create(configuration_file)}.to raise_configuration_error m
    end
  end

  context "入力が負数のとき" do
    it "RGen::ConfigurationErrorを発生させる" do
      ConfigurationDummyLoader.load_data({address_width: -1})
      m = "zero/negative address width is not allowed: -1"
      expect{@factory.create(configuration_file)}.to raise_configuration_error m
    end
  end
end
