require_relative '../spec_helper'

describe 'bit_field/initial_value' do
  include_context 'register_map common'
  include_context 'configuration common'

  before(:all) do
    RGen.enable(:register_block , :name          )
    RGen.enable(:register       , :name          )
    RGen.enable(:bit_field      , :bit_assignment)
    RGen.enable(:bit_field      , :initial_value )
    @factory  = build_register_map_factory
  end

  before(:all) do
    RGen.enable(:global, :data_width)
    @configuration_factory  = build_configuration_factory
  end

  after(:all) do
    clear_enabled_items
  end

  let(:configuration) do
    ConfigurationDummyLoader.load_data(data_width: data_width)
    @configuration_factory.create(configuration_file)
  end

  let(:data_width) do
    32
  end

  describe "#initial_value" do
    before do
      RegisterMapDummyLoader.load_data("block_0" => load_data)
    end

    let(:register_map) do
      @factory.create(configuration, register_map_file)
    end

    context "空セルが与えられた場合" do
      let(:values) do
        [nil, "", "  "]
      end

      let(:load_data) do
        [
          [nil, nil         , "block_0", nil      ],
          [nil, nil         , nil      , nil      ],
          [nil, nil         , nil      , nil      ],
          [nil, "register_0", "[3:0]"  , values[0]],
          [nil, "register_1", "[3:0]"  , values[1]],
          [nil, "register_2", "[3:0]"  , values[2]]
        ]
      end

      it "0を返す" do
        expect(register_map.bit_fields.map(&:initial_value)).to all(eq 0)
      end
    end

    context "適切な入力が与えられた場合" do
      let(:valid_values) do
        [-8, "-7", -2.0, "-0x1", 0, "0x1", 2.0, "14", 15]
      end

      let(:expected_values) do
        valid_values.map(&method(:Integer))
      end

      let(:load_data) do
        [
          [nil, nil         , "block_0", nil            ],
          [nil, nil         , nil      , nil            ],
          [nil, nil         , nil      , nil            ],
          [nil, "register_0", "[3:0]"  , valid_values[0]],
          [nil, nil         , "[7:4]"  , valid_values[1]],
          [nil, nil         , "[11:8]" , valid_values[2]],
          [nil, "register_1", "[3:0]"  , valid_values[3]],
          [nil, nil         , "[7:4]"  , valid_values[4]],
          [nil, nil         , "[11:8]" , valid_values[5]],
          [nil, "register_2", "[3:0]"  , valid_values[6]],
          [nil, nil         , "[7:4]"  , valid_values[7]],
          [nil, nil         , "[11:8]" , valid_values[8]]
        ]
      end

      it "入力された初期値を返す" do
        expect(register_map.bit_fields.map(&:initial_value)).to match expected_values
      end
    end
  end

  context "入力が整数に変換できなかったとき" do
    let(:invalid_values) do
      ["1.0", "foo", "0x-1", "0xGH"]
    end

    it "RegisterMapErrorを発生させる" do
      invalid_values.each do |value|
        RegisterMapDummyLoader.load_data(
          "block_0" => [
            [nil, nil         , "block_0", nil  ],
            [nil, nil         , nil      , nil  ],
            [nil, nil         , nil      , nil  ],
            [nil, "register_0", "[3:0]"  , value]
          ]
        )

        message = "invalid value for initial value: #{value.inspect}"
        expect {
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error(message, position("block_0", 3, 3))
      end
    end
  end

  context "入力がビットフィールド幅の範囲を超えたとき" do
    let(:invalid_values) do
      [-9.0, "0x10"]
    end

    let(:valid_range) do
      -8..15
    end

    it "RegisterMapErrorを発生させる" do
      invalid_values.each do |value|
        RegisterMapDummyLoader.load_data(
          "block_0" => [
            [nil, nil         , "block_0", nil  ],
            [nil, nil         , nil      , nil  ],
            [nil, nil         , nil      , nil  ],
            [nil, "register_0", "[3:0]"  , value]
          ]
        )

        message = "out of valid initial value range(#{valid_range}): #{Integer(value)}"
        expect {
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error(message, position("block_0", 3, 3))
      end
    end
  end
end
