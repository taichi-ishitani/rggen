require_relative '../spec_helper'

describe 'register/offset_address' do
  include_context 'register_map common'
  include_context 'configuration common'

  before(:all) do
    enable :register_block, :byte_size
    enable :register      , :offset_address
    @factory  = build_register_map_factory
  end

  before(:all) do
    enable :global, :address_width
    enable :global, :data_width
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

  let(:byte_size) do
    256
  end

  def set_load_data(value_or_values)
    data  = [
      [nil, nil, byte_size],
      [                   ],
      [                   ]
    ]
    data.concat(Array(value_or_values))
    RegisterMapDummyLoader.load_data("block_0" => data)
  end

  context "適切な入力が与えられた場合" do
    let(:valid_values) do
      {
        "0x00"         => [0x00, 0x03],
        "0x04-0x07"    => [0x04, 0x07],
        "0x08 -0x0F"   => [0x08, 0x0F],
        "0x10- 0x1B"   => [0x10, 0x1B],
        "0x1C - 0x2F"  => [0x1C, 0x2F],
        "0x3_0-0x43"   => [0x30, 0x43],
        "0x48"         => [0x48, 0x4B],
        "0x44"         => [0x44, 0x47],
        "0xFC-0xFF"    => [0xFC, 0xFF]
      }
    end

    let(:load_data) do
      cell_values = valid_values.keys
      [
        [nil, cell_values[0]],
        [nil, cell_values[1]],
        [nil, cell_values[2]],
        [nil, cell_values[3]],
        [nil, cell_values[4]],
        [nil, cell_values[5]],
        [nil, cell_values[6]],
        [nil, cell_values[7]],
        [nil, cell_values[8]]
      ]
    end

    let(:register_map) do
      set_load_data(load_data)
      @factory.create(configuration, register_map_file)
    end

    describe "#start_address/#end_address/#byte_size" do
      it "入力されたスタートアドレス/エンドアドレス/バイトサイズを返す" do
        valid_values.values.each_with_index do |(start_address, end_address), i|
          expect(register_map.registers[i]).to match_offset_address(start_address, end_address)
        end
      end
    end

    context "#byte_sizeがデータ幅と同じとき" do
      describe "#single?" do
        it "真を返す" do
          expect(register_map.registers[0]).to be_single
          expect(register_map.registers[1]).to be_single
        end
      end

      describe "#multiple?" do
        it "偽を返す" do
          expect(register_map.registers[0]).not_to be_multiple
          expect(register_map.registers[1]).not_to be_multiple
        end
      end
    end

    context "#byte_sizeがデータ幅より大きいとき" do
      describe "#single?" do
        it "偽を返す" do
          expect(register_map.registers[2]).not_to be_single
          expect(register_map.registers[3]).not_to be_single
        end
      end

      describe "#multiple?" do
        it "真を返す" do
          expect(register_map.registers[2]).to be_multiple
          expect(register_map.registers[3]).to be_multiple
        end
      end
    end
  end

  context "入力がオフセットアドレスに適さないとき" do
    let(:invalid_values) do
      ["foo", "-0x4", "0x00 - -0x4", "0x_0", "0x0\n-0x3"]
    end

    it "RegisterMapErrorを発生させる" do
      invalid_values.each do |value|
        set_load_data([
          [nil, value]
        ])

        message = "invalid value for offset address: #{value.inspect}"
        expect {
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error(message, position("block_0", 3, 1))
      end
    end
  end

  context "スタートアドレスとエンドアドレスが等しく、" do
    before do
      set_load_data([
        [nil, address_value]
      ])
    end

    let(:address_value) do
      "0x00 - 0x00"
    end

    context "データ幅が16ビット以上の場合" do
      let(:data_width) do
        16
      end

      it "RegisterMapErrorを発生させる" do
        message = "start address is equal to or greater than end address: #{address_value}"
        expect{
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error(message, position("block_0", 3, 1))
      end
    end

    context "8ビットの場合" do
      let(:data_width) do
        8
      end

      it "エラーは発生しない" do
        expect{
          @factory.create(configuration, register_map_file)
        }.not_to raise_error
      end
    end
  end

  context "スタートアドレスがエンドアドレスより大きいとき" do
    let(:invalid_value) do
      "0x03 - 0x00"
    end

    it "RegisterMapErrorを発生させる" do
      set_load_data([
        [nil, invalid_value]
      ])

      message = "start address is equal to or greater than end address: #{invalid_value}"
      expect{
        @factory.create(configuration, register_map_file)
      }.to raise_register_map_error(message, position("block_0", 3, 1))
    end
  end

  context "スタートアドレス、エンドアドレスがデータ幅に揃っていないとき" do
    let(:invalid_values) do
      ["0x01", "0x00-0x01", "0x01-0x04"]
    end

    it "RegisterMapErrorを発生させる" do
      invalid_values.each do |value|
        set_load_data([
          [nil, value]
        ])

        message = "not aligned with data width(#{data_width}): #{value}"
        expect{
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error(message, position("block_0", 3, 1))
      end
    end
  end

  context "スタートアドレス、エンドアドレスがデータ幅に揃っていないとき" do
    let(:invalid_values) do
      ["0x01", "0x00-0x01", "0x01-0x04"]
    end

    it "RegisterMapErrorを発生させる" do
      invalid_values.each do |value|
        set_load_data([
          [nil, value]
        ])

        message = "not aligned with data width(#{data_width}): #{value}"
        expect{
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error(message, position("block_0", 3, 1))
      end
    end
  end

  context "最大アドレスを超えるとき" do
    let(:invalid_values) do
      ["0x100", "0xFC-0x103"]
    end

    it "RegisterMapErrorを発生させる" do
      invalid_values.each do |value|
        set_load_data([
          [nil, value]
        ])

        message = "exceeds the maximum offset address(0xff): #{value}"
        expect{
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error(message, position("block_0", 3, 1))
      end
    end
  end
end
