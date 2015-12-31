require_relative '../spec_helper'

describe 'register/array' do
  include_context 'bit field type common'
  include_context 'configuration common'

  before(:all) do
    enable :register_block, [:name, :byte_size]
    enable :register      , [:name, :offset_address, :array]
  end

  before(:all) do
    enable :global, [:data_width, :address_width]
    @configuration  = create_configuration(data_width: 32, address_width: 16)
  end

  after(:all) do
    clear_enabled_items
  end

  let(:configuration) do
    @configuration
  end

  describe 'register_map' do
    before(:all) do
      @factory  = build_register_map_factory
    end

    let(:registers) do
      set_load_data(load_data)
      @factory.create(configuration, register_map_file).registers
    end

    def set_load_data(data)
      block_data  = [
        [nil, nil, "block_0"],
        [nil, nil, 256      ],
        [                   ],
        [                   ]
      ]
      block_data.concat(data)
      RegisterMapDummyLoader.load_data("block_0" => block_data)
    end

    context "入力がnilや空文字の場合" do
      let(:load_data) do
        [
          [nil, "register_0", "0x00"     , nil],
          [nil, "register_1", "0x04-0x0B", "" ]
        ]
      end

      describe "#array?" do
        it "偽を返す" do
          expect(registers.map(&:array?)).to all(be_falsey)
        end
      end

      describe "#dimensions" do
        it "nilを返す" do
          expect(registers.map(&:dimensions)).to all(be_nil)
        end
      end
    end

    context "適切な入力が与えられた場合" do
      let(:load_data) do
        [
          [nil, "register_0", "0x00"     , "[ 1]" ],
          [nil, "register_1", "0x04-0x0B", "[2 ]" ],
          [nil, "register_2", "0x20-0x47", "[10]"]
        ]
      end

      describe "#array?" do
        it "真を返す" do
          expect(registers.map(&:array?)).to all(be_truthy)
        end
      end

      describe "#dimensions" do
        it "次元を配列で返す" do
          expect(registers.map(&:dimensions)).to match([
            [1], [2], [10]
          ])
        end
      end
    end

    context "入力が配列設定に適さないとき" do
      let(:invalid_values) do
        ["[0]", "[01]", "[1.0]", "[1", "1]", "1", "[1\t]", "[\n1]", "foo"]
      end

      it "RegisterMapErrorを発生させる" do
        invalid_values.each do |invalid_value|
          set_load_data([
            [nil, "register_0", "0x00", invalid_value]
          ])

          message = "invalid value for array dimension: #{invalid_value.inspect}"
          expect {
            @factory.create(configuration, register_map_file)
          }.to raise_register_map_error(message, position("block_0", 4, 3))
        end
      end
    end

    context "配列の大きさと自身のバイトサイズが合わないとき" do
      let(:invalid_values) do
        [1, 3]
      end

      it "RegisterMapErrorを発生させる" do
        invalid_values.each do |invalid_value|
          set_load_data([
            [nil, "register_0", "0x00-0x07", "[#{invalid_value}]"]
          ])

          message = "mismatches with own byte size(8): #{[invalid_value]}"
          expect {
            @factory.create(configuration, register_map_file)
          }.to raise_register_map_error(message, position("block_0", 4, 3))
        end
      end
    end
  end
end
