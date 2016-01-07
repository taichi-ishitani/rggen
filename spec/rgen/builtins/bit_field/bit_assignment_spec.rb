require_relative '../spec_helper'

describe 'bit_field/bit_assignment' do
  include_context 'register_map common'
  include_context 'configuration common'

  before(:all) do
    RGen.enable(:register_block , :name          )
    RGen.enable(:register       , :name          )
    RGen.enable(:bit_field      , :bit_assignment)
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

  context "適切な入力が与えられた場合" do
    describe "#msb/#lsb/#width" do
      let(:valid_values) do
        {
          "[0]"         => [0 , 0 ],
          "[ 1]"        => [1 , 1 ],
          "[8 ]"        => [8 , 8 ],
          "[7:0]"       => [7 ,0  ],
          "[ 8:8 ]"     => [8 , 8 ],
          "[15 : 9]"    => [15, 9 ],
          "[ 23 : 16 ]" => [23, 16],
          "[31:0]"      => [31, 0 ],
          "[31]"        => [31, 31],
          "[30:0]"      => [30, 0 ]
        }
      end

      let(:load_data) do
        {
          "block_0" => [
            [nil, nil         , "block_0"           ],
            [nil, nil         , nil                 ],
            [nil, nil         , nil                 ],
            [nil, "register_0", valid_values.keys[0]],
            [nil, nil         , valid_values.keys[1]],
            [nil, nil         , valid_values.keys[2]],
            [nil, "register_1", valid_values.keys[3]],
            [nil, nil         , valid_values.keys[4]],
            [nil, nil         , valid_values.keys[5]],
            [nil, nil         , valid_values.keys[6]],
            [nil, "register_2", valid_values.keys[7]],
            [nil, "register_3", valid_values.keys[8]],
            [nil, nil         , valid_values.keys[9]]
          ]
        }
      end

      let(:register_map) do
        @factory.create(configuration, register_map_file)
      end

      before do
        RegisterMapDummyLoader.load_data(load_data)
      end

      it "入力されたmsb/lsb/ビット幅を返す" do
        valid_values.values.each_with_index do |(msb, lsb), i|
          expect(register_map.bit_fields[i]).to match_bit_assignment(msb, lsb)
        end
      end
    end
  end

  context "入力がビット割り当てに適さないとき" do
    let(:invalid_values) do
      ["[01]", "[0.0]", "[0", "0]", "0", "[0\n]", "[01:0]", "[1:00]", "[1\n:0]", "foo"]
    end

    it "RegisterMapErrorを発生させる" do
      invalid_values.each do |invalid_value|
        RegisterMapDummyLoader.load_data(
          "block_0" => [
            [nil, nil         , "block_0"    ],
            [nil, nil         , nil          ],
            [nil, nil         , nil          ],
            [nil, "register_0", invalid_value]
          ]
        )

        message = "invalid value for bit assignment: #{invalid_value.inspect}"
        expect {
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error(message, position("block_0", 3, 2))
      end
    end
  end

  context "LSBがMSBより大きいとき" do
    let(:invalid_value) do
      "[0:1]"
    end

    it "RegisterMapErrorを発生させる" do
      RegisterMapDummyLoader.load_data(
        "block_0" => [
          [nil, nil         , "block_0"    ],
          [nil, nil         , nil          ],
          [nil, nil         , nil          ],
          [nil, "register_0", invalid_value]
        ]
      )

      message = "lsb is larger than msb: #{invalid_value}"
      expect{
        @factory.create(configuration, register_map_file)
      }.to raise_register_map_error(message, position("block_0", 3, 2))
    end
  end

  context "データ幅を超えるとき" do
    let(:invalid_values) do
      ["[32:31]", "[32]"]
    end

    it "RegisterMapErrorを発生させる" do
      invalid_values.each do |invalid_value|
        RegisterMapDummyLoader.load_data(
          "block_0" => [
            [nil, nil         , "block_0"    ],
            [nil, nil         , nil          ],
            [nil, nil         , nil          ],
            [nil, "register_0", invalid_value]
          ]
        )

        message = "exceeds the data width(#{data_width}): #{invalid_value}"
        expect {
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error(message, position("block_0", 3, 2))
      end
    end
  end

  context "入力ビット割り当てが重複するとき" do
    let(:invalid_values) do
      ["[4]", "[7]", "[4:3]", "[8:7]", "[7:4]", "[6:5]", "[8:3]"]
    end

    it "RegisterMapErrorを発生させる" do
      invalid_values.each do |invalid_value|
        RegisterMapDummyLoader.load_data(
          "block_0" => [
            [nil, nil         , "block_0"    ],
            [nil, nil         , nil          ],
            [nil, nil         , nil          ],
            [nil, "register_0", "[7:4]"      ],
            [nil, nil         , invalid_value]
          ]
        )

        message = "overlapped bit assignment: #{invalid_value}"
        expect {
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error(message, position("block_0", 4, 2))
      end
    end
  end
end