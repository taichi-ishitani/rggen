require_relative '../spec_helper'

describe 'register/uniqueness_validator' do
  include_context 'register_map common'
  include_context 'configuration common'

  before(:all) do
    enable :register_block, :byte_size
    enable :register      , [:offset_address, :array, :shadow, :uniqueness_validator]
    enable :bit_field     , [:name, :bit_assignment, :type, :initial_value]
    enable :bit_field     , :type, [:ro, :reserved]
    @factory  = build_register_map_factory
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

  let(:index_registers) do
    [
      [nil, "0x00", nil, "", "index_0", "[9:8]", "ro", nil],
      [nil, nil   , nil, "", "index_1", "[1:0]", "ro", nil],
      [nil, "0x04", nil, "", "index_2", "[9:8]", "ro", nil],
      [nil, nil   , nil, "", "index_3", "[1:0]", "ro", nil]
    ]
  end

  def set_load_data(data)
    block_data  = [
      [nil, nil, 256],
      [             ],
      [             ]
    ]
    block_data.concat(data)
    RegisterMapDummyLoader.load_data("block_0" => block_data)
  end

  context "オフセットアドレスとシャドウインデックスに重複がない場合" do
    before do
      set_load_data([
        *index_registers,
        [nil, "0x08"     , nil        , nil                         , "bit_field_0_0" , "[31:0]", "ro", nil],
        [nil, "0x10-0x1F", "[4]"      , nil                         , "bit_field_1_0" , "[31:0]", "ro", nil],
        [nil, "0x20"     , nil        , "index_0:0"                 , "bit_field_2_0" , "[31:0]", "ro", nil],
        [nil, "0x20"     , nil        , "index_0:1"                 , "bit_field_3_0" , "[31:0]", "ro", nil],
        [nil, "0x24"     , nil        , "index_0:0"                 , "bit_field_4_0" , "[31:0]", "ro", nil],
        [nil, "0x24"     , nil        , "index_1:0"                 , "bit_field_5_0" , "[31:0]", "ro", nil],
        [nil, "0x28"     , nil        , "index_0:0, index_1:0"      , "bit_field_6_0" , "[31:0]", "ro", nil],
        [nil, "0x28"     , nil        , "index_0:0, index_1:1"      , "bit_field_7_0" , "[31:0]", "ro", nil],
        [nil, "0x2C"     , nil        , "index_0:0, index_1:0"      , "bit_field_8_0" , "[31:0]", "ro", nil],
        [nil, "0x2C"     , nil        , "index_0:0, index_2:0"      , "bit_field_9_0" , "[31:0]", "ro", nil],
        [nil, "0x30"     , "[4]"      , "index_0"                   , "bit_field_10_0", "[31:0]", "ro", nil],
        [nil, "0x30"     , "[4]"      , "index_1"                   , "bit_field_11_0", "[31:0]", "ro", nil],
        [nil, "0x34"     , "[4, 4]"   , "index_0, index_1"          , "bit_field_12_0", "[31:0]", "ro", nil],
        [nil, "0x34"     , "[4, 4]"   , "index_0, index_2"          , "bit_field_13_0", "[31:0]", "ro", nil],
        [nil, "0x38"     , "[4]"      , "index_0"                   , "bit_field_14_0", "[31:0]", "ro", nil],
        [nil, "0x38"     , "[4, 4, 4]", "index_1, index_2, index_3" , "bit_field_15_0", "[31:0]", "ro", nil],
        [nil, "0x40"     , "[4]"      , "index_0, index_1:0"        , "bit_field_16_0", "[31:0]", "ro", nil],
        [nil, "0x40"     , "[4]"      , "index_0, index_1:1"        , "bit_field_17_0", "[31:0]", "ro", nil],
        [nil, "0x44"     , "[4]"      , "index_0, index_1:0"        , "bit_field_18_0", "[31:0]", "ro", nil],
        [nil, "0x44"     , "[4]"      , "index_0, index_2:0"        , "bit_field_19_0", "[31:0]", "ro", nil],
        [nil, "0x48"     , "[4]"      , "index_0:0, index_1"        , "bit_field_20_0", "[31:0]", "ro", nil],
        [nil, "0x48"     , "[4]"      , "index_0:1, index_2"        , "bit_field_21_0", "[31:0]", "ro", nil],
      ])
    end

    specify "エラーなくレジスタマップを生成できる" do
      expect {
        @factory.create(configuration, register_map_file)
      }.not_to raise_error
    end
  end

  context "オフセットアドレスが重複するとき" do
    let(:invalid_values) do
      [
        ["0x04"     , nil              ],
        ["0x08"     , nil              ],
        ["0x10"     , nil              ],
        ["0x00-0x07", nil              ],
        ["0x10-0x17", nil              ],
        ["0x08-0x0F", nil              ],
        ["0x04-0x13", nil              ],
        ["0x24"     , "bit_field_1_0:0"],
        ["0x28"     , nil              ]
      ]
    end

    it "RegisterMapErrorを発生させる" do
      invalid_values.each do |address, shadow|
        set_load_data([
          [nil, "0x04-0x13", nil, nil              , "bit_field_0_0", "[31:0]", "ro", nil],
          [nil, "0x20"     , nil, nil              , "bit_field_1_0", "[31:0]", "ro", nil],
          [nil, "0x24"     , nil, nil              , "bit_field_2_0", "[31:0]", "ro", nil],
          [nil, "0x28"     , nil, "bit_field_1_0:0", "bit_field_3_0", "[31:0]", "ro", nil],
          [nil, address    , nil, shadow           , "bit_field_4_0", "[31:0]", "ro", nil]
        ])

        message = "offset address is not unique"
        expect{
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error(message, position("block_0", 7, 1))
      end
    end
  end

  context "同一アドレスのシャドウインデックスが重なる場合" do
    let(:invalid_value_pairs) do
      [
        [["[2]"   , "index_0"                    ], ["[2]"   , "index_0"                      ]],
        [[nil     , "index_0:0"                  ], [nil     , "index_0:0"                    ]],
        [["[2]"   , "index_0"                    ], [nil     , "index_0:0"                    ]],
        [[nil     , "index_0:0"                  ], ["[2]"   , "index_0"                      ]],
        [["[2]"   , "index_0, index_1:0"         ], ["[2]"   , "index_0, index_1:0"           ]],
        [["[2]"   , "index_0, index_1:0"         ], ["[2, 2]", "index_0, index_1:0, index_2"  ]],
        [["[2]"   , "index_0, index_1:0"         ], ["[2]"   , "index_0, index_1:0, index_2:0"]],
        [["[2, 2]", "index_0, index_1:0, index_2"], ["[2]"   , "index_0, index_1:0"           ]],
        [["[2, 2]", "index_0, index_1:0, index_2"], ["[2, 2]", "index_0, index_2"             ]]
      ]
    end

    it "RegisterMapErrorを発生させる" do
      invalid_value_pairs.each do |invalid_value_pair|
        set_load_data([
          *index_registers,
          [nil, "0x08", invalid_value_pair[0][0], invalid_value_pair[0][1], "bit_field_0_0", "[31:0]", "ro", nil],
          [nil, "0x08", invalid_value_pair[1][0], invalid_value_pair[1][1], "bit_field_1_0", "[31:0]", "ro", nil]
        ])

        message = "shadow indexes is not unique"
        expect {
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error(message, position("block_0", 8, 3))
      end
    end
  end
end
