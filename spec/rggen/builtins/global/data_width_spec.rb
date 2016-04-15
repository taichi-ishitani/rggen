require_relative '../spec_helper'

describe "global/data_width" do
  include_context 'configuration common'

  before(:all) do
    RgGen.enable(:global, :data_width)
    @factory  = build_configuration_factory
  end

  after(:all) do
    clear_enabled_items
  end

  describe "#data_width/#byte_width" do
    context "ロード結果のHashに:data_widthが含まれないとき" do
      it "デフォルト値(32/4)を返す" do
        ConfigurationDummyLoader.load_data({})
        c = @factory.create(configuration_file)
        expect(c).to match_data_width(32)
      end
    end

    context "ロード結果のHashに:data_widthが含まれていて、8以上の2のべき乗に変換できるとき" do
      let(:load_data) do
        [8, "16", 32.0, "0x40"]
      end

      it "変換結果を返す(byte_sizeはdata_widthの8分の1)" do
        load_data.each do |data|
          ConfigurationDummyLoader.load_data({data_width: data})
          c = @factory.create(configuration_file)
          expect(c).to match_data_width(Integer(data))
        end
      end
    end
  end

  context "入力が整数に変換できなかったとき" do
    let(:load_data) do
      ["1.0", "foo", "0xGH", Object.new, []]
    end

    it "RgGen::ConfigurationErrorを発生させる" do
      load_data.each do |data|
        ConfigurationDummyLoader.load_data({data_width: data})
        m = "invalid value for data width: #{data.inspect}"
        expect{@factory.create(configuration_file)}.to raise_configuration_error m
      end
    end
  end

  context "入力が8未満のとき" do
    it "RgGen::ConfigurationErrorを発生させる" do
      ConfigurationDummyLoader.load_data({data_width: 4})
      m = "under 8/non-power of 2 data width is not allowed: 4"
      expect{@factory.create(configuration_file)}.to raise_configuration_error m
    end
  end

  context "入力が2のべき乗でないのとき" do
    it "RgGen::ConfigurationErrorを発生させる" do
      ConfigurationDummyLoader.load_data({data_width: 9})
      m = "under 8/non-power of 2 data width is not allowed: 9"
      expect{@factory.create(configuration_file)}.to raise_configuration_error m
    end
  end
end
