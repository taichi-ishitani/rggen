require_relative '../spec_helper'

describe 'base address/register_map' do
  include_context 'register_map common'
  include_context 'configuration common'

  before(:all) do
    RGen.enable(:register_block, :base_address)
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
    describe "#start_address/end_address" do
      let(:valid_values) do
        [
          ["0x0000-0x0FFF"   , 0x0000, 0x0FFF],
          ["0x1000 -0x2fff"  , 0x1000, 0x2FFF],
          ["0x3000- 0x3fFB"  , 0x3000, 0x3FFB],
          ["0X400C\t- 0x4FFF", 0x400C, 0x4FFF],
          ["0x5000 -\t0x5FFF", 0x5000, 0x5FFF],
          ["0x60_00-0x6FFF_" , 0x6000, 0x6FFF],
          ["0x7000 - 0x7003" , 0x7000, 0x7003],
          ["0xFFFC - 0xFFFF" , 0xFFFC, 0xFFFF]
        ]
      end

      let(:load_data) do
        valid_values.size.times.with_object({}) do |i, hash|
          hash["block_#{i}"]  = [
            [nil, nil, valid_values[i][0]]
          ]
        end
      end

      let(:register_map) do
        @factory.create(configuration, register_map_file)
      end

      before do
        RegisterMapDummyLoader.load_data(load_data)
      end

      it "入力されたスタートアドレス/エンドアドレスを返す" do
        valid_values.each_with_index do |(_, start_address, end_address), i|
          expect(register_map.register_blocks[i]).to match_base_address(start_address, end_address)
        end
      end
    end
  end

  context "入力がベースアドレスに適さないとき" do
    let(:invalid_values) do
      ["foo", "012-ABC", "0b000-0b111", "0o0-0o3", "0-3", "0x_0000-0x0FFF", "0x0000\n-0x0FFF", "0x0000"]
    end

    it "RegisterMapErrorを発生させる" do
      invalid_values.each do |value|
        load_data = {
          "block_0" => [
            [nil, nil, value]
          ]
        }
        RegisterMapDummyLoader.load_data(load_data)

        message = "invalid value for base address: #{value.inspect}"
        expect{
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error(message, position("block_0", 0, 2))
      end
    end
  end

  context "スタートアドレスとエンドアドレスが等しいとき" do
    let(:load_data) do
      {"block_0" => [
        [nil, nil, "0x0000 - 0x0000"]
      ]}
    end

    before do
      RegisterMapDummyLoader.load_data(load_data)
    end

    it "RegisterMapErrorを発生させる" do
      message = "start address is equal to or greater than end address: 0x0000 - 0x0000"
      expect{
        @factory.create(configuration, register_map_file)
      }.to raise_register_map_error(message, position("block_0", 0, 2))
    end
  end

  context "スタートアドレスがエンドアドレスより大きいとき" do
    let(:load_data) do
      {"block_0" => [
        [nil, nil, "0x0004 - 0x0003"]
      ]}
    end

    before do
      RegisterMapDummyLoader.load_data(load_data)
    end

    it "RegisterMapErrorを発生させる" do
      message = "start address is equal to or greater than end address: 0x0004 - 0x0003"
      expect{
        @factory.create(configuration, register_map_file)
      }.to raise_register_map_error(message, position("block_0", 0, 2))
    end
  end

  context "最大アドレスを超えたとき" do
    let(:load_data) do
      {"block_0" => [
        [nil, nil, "0x0_fffc - 0x1_0003"]
      ]}
    end

    before do
      RegisterMapDummyLoader.load_data(load_data)
    end

    it "RegisterMapErrorを発生させる" do
      message = "exceeds the maximum base address(0xffff): 0x0_fffc - 0x1_0003"
      expect{
        @factory.create(configuration, register_map_file)
      }.to raise_register_map_error(message, position("block_0", 0, 2))
    end
  end

  context "スタートアドレス、エンドアドレスがデータ幅でアラインメントされていないとき" do
    let(:invalid_values) do
      ["0x0001-0x0003", "0x0000-0x0004", "0x0001-0x0002"]
    end

    it "RegisterMapErrorを発生させる" do
      invalid_values.each do |value|
        load_data = {
          "block_0" => [
            [nil, nil, value]
          ]
        }
        RegisterMapDummyLoader.load_data(load_data)

        message = "unaligned base address: #{value}"
        expect{
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error(message, position("block_0", 0, 2))
      end
    end
  end

  context "入力アドレスが重複するとき" do
    let(:invalid_values) do
      ["0x0FFC-0x1003", "0x1FFC-0x2003", "0x1000-0x1FFF", "0x1004-0x1FFB", "0x0FFC-0x2003"]
    end

    it "RegisterMapErrorを発生させる" do
      invalid_values.each do |value|
        load_data = {
          "block_0" => [
            [nil, nil, "0x1000-0x1FFF"]
          ],
          "block_1" => [
            [nil, nil, value]
          ]
        }
        RegisterMapDummyLoader.load_data(load_data)

        message = "overlapped base address: #{value}"
        expect{
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error(message, position("block_1", 0, 2))
      end
    end
  end
end
