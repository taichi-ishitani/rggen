require_relative '../spec_helper'

describe 'register_map/byte_size' do
  include_context 'register_map common'
  include_context 'configuration common'

  before(:all) do
    RGen.enable(:register_block, :byte_size)
    @factory  = build_register_map_factory
  end

  before(:all) do
    RGen.enable(:global, :address_width)
    RGen.enable(:global, :data_width   )
    @configuration_factory  = build_configuration_factory
  end

  after(:all) do
    clear_enabled_items
  end

  let(:configuration) do
    ConfigurationDummyLoader.load_data(address_width: address_width, data_width: data_width)
    @configuration_factory.create(configuration_file)
  end

  let(:address_width) do
    16
  end

  let(:data_width) do
    32
  end

  context "適切な入力が与えられた場合" do
    let(:valid_values) do
      [4, "8", 16.0, 0xFFE4]
    end

    let(:load_data) do
      valid_values.size.times.each_with_object({}) do |i, hash|
        hash["block_#{i}"]  = [
          [nil, nil, valid_values[i]]
        ]
      end
    end

    let(:register_map) do
      @factory.create(configuration, register_map_file)
    end

    before do
      RegisterMapDummyLoader.load_data(load_data)
    end

    describe "#byte_size" do
      it "入力されたバイトサイズを返す" do
        valid_values.each_with_index do |value, i|
          expect(register_map.register_blocks[i].byte_size).to eq Integer(value)
        end
      end
    end

    describe "#local_address_width" do
      let(:expected_widths) do
        [2, 3, 4, 16]
      end

      it "内部で必要なアドレス幅を返す" do
        valid_values.each_with_index do |value, i|
          expect(register_map.register_blocks[i].local_address_width).to eq expected_widths[i]
        end
      end
    end
  end

  context "入力が整数に変換できなかったとき" do
    let(:invalid_values) do
      ["1.0", "foo", "0xGH", nil]
    end

    it "RegisterMapErrorを発生させる" do
      invalid_values.each do |value|
        RegisterMapDummyLoader.load_data("block_0" => [[nil, nil, value]])

        message = "invalid value for byte size: #{value.inspect}"
        expect{
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error(message, position("block_0", 0, 2))
      end
    end
  end

  context "入力が0のとき" do
    let(:load_data) do
      {"block_0" => [
        [nil, nil, 0]
      ]}
    end

    before do
      RegisterMapDummyLoader.load_data(load_data)
    end

    it "RegisterMapErrorを発生させる" do
      message = "zero or negative value is not allowed for byte size: 0"
      expect{
        @factory.create(configuration, register_map_file)
      }.to raise_register_map_error(message, position("block_0", 0, 2))
    end
  end

  context "入力が負数のとき" do
    let(:load_data) do
      {"block_0" => [
        [nil, nil, -1]
      ]}
    end

    before do
      RegisterMapDummyLoader.load_data(load_data)
    end

    it "RegisterMapErrorを発生させる" do
      message = "zero or negative value is not allowed for byte size: -1"
      expect{
        @factory.create(configuration, register_map_file)
      }.to raise_register_map_error(message, position("block_0", 0, 2))
    end
  end

  context "入力がデータ幅に揃っていないとき" do
    let(:invalid_values) do
      [3, 5, 0x101]
    end

    it "RegisterMapErrorを発生させる" do
      invalid_values.each do |value|
        RegisterMapDummyLoader.load_data("block_0" => [[nil, nil, value]])

        message = "not aligned with data width(#{data_width}): #{value}"
        expect{
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error(message, position("block_0", 0, 2))
      end
    end
  end

  context "入力されたバイトサイズの合計が最大値を超えたとき" do
    let(:values) do
      [0x8000, 0x8000, 0x4]
    end

    let(:load_data) do
      values.size.times.each_with_object({}) do |i, hash|
        hash["block_#{i}"]  = [
          [nil, nil, values[i]]
        ]
      end
    end

    let(:upper_bound) do
      2**address_width
    end

    let(:total_size) do
      values.inject(0) {|sum, value| sum + value}
    end

    before do
      RegisterMapDummyLoader.load_data(load_data)
    end

    it "RegisterMapErrorを発生させる" do
      message = "exceeds upper bound of total byte size(#{upper_bound}): #{total_size}"
      expect{
        @factory.create(configuration, register_map_file)
      }.to raise_register_map_error(message, position("block_2", 0, 2))
    end
  end
end
