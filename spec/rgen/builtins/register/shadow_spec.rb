require_relative '../spec_helper'

describe 'register/shadow' do
  include_context 'bit field type common'
  include_context 'configuration common'

  before(:all) do
    enable :register_block, [:name, :byte_size]
    enable :register      , [:name, :offset_address, :array, :shadow]
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

  let(:registers) do
    set_load_data(load_data)
    @factory.create(configuration, register_map_file).registers
  end

  let(:index_registers) do
    [
      [nil, "index_0", "0x00", nil, "", "index_0", "[9:8]", "ro", nil],
      [nil, nil      , nil   , nil, "", "index_1", "[1:0]", "ro", nil],
      [nil, "index_1", "0x04", nil, "", "index_2", "[9:8]", "ro", nil],
      [nil, nil      , nil   , nil, "", "index_3", "[1:0]", "ro", nil]
    ]
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

  context "入力がnilが空文字のとき" do
    let(:load_data) do
      [
        [nil, "register_0", "0x00"     , nil  , nil, "bit_field_0_0", "[31:0]", "ro", nil],
        [nil, "register_1", "0x04-0x0F", "[3]", "" , "bit_field_1_0", "[31:0]", "ro", nil]
      ]
    end

    describe "#shadow?" do
      it "偽を返す" do
        expect(registers.map(&:shadow?)).to all(be_falsey)
      end
    end

    describe "#shadow_indexes" do
      it "nilを返す" do
        expect(registers.map(&:shadow_indexes)).to all(be_nil)
      end
    end
  end

  context "適切な入力が与えられた場合" do
    let(:load_data) do
      [
        *index_registers,
        [nil, "register_0" , "0x08", nil        , "index_0:0"                   , "bit_field_0_0" , "[31:0]", "ro", nil],
        [nil, "register_1" , "0x08", nil        , "index_1:0"                   , "bit_field_1_0" , "[31:0]", "ro", nil],
        [nil, "register_2" , "0x0c", nil        , "index_0:0"                   , "bit_field_2_0" , "[31:0]", "ro", nil],
        [nil, "register_3" , "0x0c", nil        , "index_0:1"                   , "bit_field_3_0" , "[31:0]", "ro", nil],
        [nil, "register_4" , "0x10", nil        , "index_0:0, index_1:0"        , "bit_field_4_0" , "[31:0]", "ro", nil],
        [nil, "register_5" , "0x10", nil        , "index_0:0 ,index_2:0"        , "bit_field_5_0" , "[31:0]", "ro", nil],
        [nil, "register_6" , "0x14", nil        , "index_0:0\nindex_1:0"        , "bit_field_6_0" , "[31:0]", "ro", nil],
        [nil, "register_7" , "0x14", nil        , "index_0:0\nindex_1:1"        , "bit_field_7_0" , "[31:0]", "ro", nil],
        [nil, "register_8" , "0x18", "[4]"      , "index_0"                     , "bit_field_8_0" , "[31:0]", "ro", nil],
        [nil, "register_9" , "0x18", "[2]"      , "index_1"                     , "bit_field_9_0" , "[31:0]", "ro", nil],
        [nil, "register_10", "0x20", "[2, 4]"   , "index_0, index_1"            , "bit_field_10_0", "[31:0]", "ro", nil],
        [nil, "register_11", "0x20", "[2, 4]"   , "index_0, index_2"            , "bit_field_11_0", "[31:0]", "ro", nil],
        [nil, "register_12", "0x24", "[2]"      , "index_0"                     , "bit_field_12_0", "[31:0]", "ro", nil],
        [nil, "register_13", "0x24", "[2, 2, 2]", "index_1, index_2, index_3"   , "bit_field_13_0", "[31:0]", "ro", nil],
        [nil, "register_14", "0x28", "[2, 4]"   , "index_0, index_1: 0, index_2", "bit_field_14_0", "[31:0]", "ro", nil],
        [nil, "register_15", "0x28", "[2, 4]"   , "index_0, index_1: 1\nindex_2", "bit_field_15_0", "[31:0]", "ro", nil]
      ]
    end

    describe "#shadow?" do
      it "真を返す" do
        expect(registers[2..-1].map(&:shadow?)).to all(be_truthy)
      end
    end

    describe "#shadow_indexes" do
      it "入力されたシャドウレジスタ用のインデックスを返す" do
        expect(registers[2..-1].map(&:shadow_indexes).map { |shadow_indexes|
          shadow_indexes.map(&:values)
        }).to match([
          [["index_0", 0  ]                                    ],
          [["index_1", 0  ]                                    ],
          [["index_0", 0  ]                                    ],
          [["index_0", 1  ]                                    ],
          [["index_0", 0  ], ["index_1", 0  ]                  ],
          [["index_0", 0  ], ["index_2", 0  ]                  ],
          [["index_0", 0  ], ["index_1", 0  ]                  ],
          [["index_0", 0  ], ["index_1", 1  ]                  ],
          [["index_0", nil],                                   ],
          [["index_1", nil],                                   ],
          [["index_0", nil], ["index_1", nil]                  ],
          [["index_0", nil], ["index_2", nil]                  ],
          [["index_0", nil]                                    ],
          [["index_1", nil], ["index_2", nil], ["index_3", nil]],
          [["index_0", nil], ["index_1", 0  ], ["index_2", nil]],
          [["index_0", nil], ["index_1", 1  ], ["index_2", nil]]
        ])
      end
    end
  end

  context "入力がシャドウインデックス設定に適さないとき" do
    let(:invalid_values) do
      ["100", "index_0,,index_1", "index_0, index_1::1"]
    end

    it "RegisterMapErrorを発生させる" do
      invalid_values.each do |invalid_value|
        set_load_data([
          [nil, "register_0", "0x08", nil, invalid_value, "bit_field_0_0", "[31:0]", "ro", nil]
        ])

        message = "invalid value for shadow index: #{invalid_value.inspect}"
        expect {
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error(message, position("block_0", 4, 4))
      end
    end
  end

  context "実配列レジスタとシャドウレジスタを同時に使用した場合" do
    it "RegisterMapErrorを発生させる" do
      set_load_data([
        [nil, "register_0", "0x08-0x0F", "[2]", "index_0", "bit_field_0_0", "[31:0]", "ro", nil]
      ])

      message = "not use real array and shadow register on the same register"
      expect {
        @factory.create(configuration, register_map_file)
      }.to raise_register_map_error(message, position("block_0", 4, 4))
    end
  end

  context "同一ビットフィールドが2回以上使われた場合" do
    let(:invalid_values) do
      ["index_0, index_0", "index_0:0, index_0:1", "index_0, index_0:0"]
    end

    it "RegisterMapErrorを発生させる" do
      invalid_values.each do |invalid_value|
        set_load_data([
          *index_registers,
          [nil, "register_0", "0x0C", nil, invalid_value, "bit_field_0_0", "[31:0]", "ro"      , nil]
        ])

        message = "not use the same index field more than once: index_0"
        expect {
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error(message, position("block_0", 8, 4))
      end
    end
  end

  context "指定したシャドウインデックスフィールドが存在しないとき" do
    let(:invalid_values) do
      [
        ["index0" , "index0"           ],
        ["index1" , "index1:0"         ],
        ["index2" , "index_0, index2"  ],
        ["index3" , "index_0, index3:0"],
        ["index_4", "index_4"          ],
        ["index_4", "index_4:0"        ]
      ]
    end

    it "RegisterMapErrorを発生させる" do
      invalid_values.each do |invalid_field, invalid_value|
        set_load_data([
          *index_registers,
          [nil, "index_2"   , "0x08", nil, nil          , "index_4"      , "[31:0]", "reserved", nil],
          [nil, "register_0", "0x0C", nil, invalid_value, "bit_field_0_0", "[31:0]", "ro"      , nil]
        ])

        message = "no such shadow index field: #{invalid_field}"
        expect {
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error(message, position("block_0", 9, 4))
      end
    end
  end

  context "自身のビットフィールドを指定している場合" do
    let(:invalid_values) do
      ["bit_field_0_0", "bit_field_0_0:0", "index_0, bit_field_0_0", "index_0, bit_field_0_0:0"]
    end

    it "RegisterMapErrorを発生させる" do
      invalid_values.each do |invalid_value|
        set_load_data([
          *index_registers,
          [nil, "register_0", "0x0C", nil, invalid_value, "bit_field_0_0", "[31:0]", "ro", nil]
        ])

        message = "own bit field is specified for shadow index field: bit_field_0_0"
        expect {
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error(message, position("block_0", 8, 4))
      end
    end
  end

  context "配列ビットフィールドを指定している場合" do
    let(:invalid_values) do
      ["index_1", "index_1:0", "index_0, index_1", "index_0, index_1:0"]
    end

    it "RegisterMapErrorを発生させる" do
      invalid_values.each do |invalid_value|
        set_load_data([
          [nil, "index_0"   , "0x00"     , nil  , nil          , "index_0"      , "[1:0]" , "ro", nil],
          [nil, "index_1"   , "0x04-0x0B", "[2]", nil          , "index_1"      , "[1:0]" , "ro", nil],
          [nil, "register_0", "0x0C"     , nil  , invalid_value, "bit_field_0_0", "[31:0]", "ro", nil]
        ])

        message = "arrayed bit field is specified for shadow index field: index_1"
        expect {
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error(message, position("block_0", 6, 4))
      end
    end
  end

  context "配列になっていないのに、配列用インデックスフィールドがある場合" do
    let(:invalid_value) do
      "index_0, index_1:0"
    end

    it "RegisterMapErrorを発生させる" do
      set_load_data([
        *index_registers,
        [nil, "register_0", "0x08", nil, invalid_value, "bit_field_0_0", "[31:0]", "ro", nil]
      ])

      message = "not match number of array dimensions and number of array index fields"
      expect {
        @factory.create(configuration, register_map_file)
      }.to raise_register_map_error(message, position("block_0", 8, 4))
    end
  end

  context "配列の次元と、配列用インデックスフィールドの個数が合わない場合" do
    let(:invalid_values) do
      ["index_0, index_1:0", "index_0, index_1:0, index_2, index_3"]
    end

    it "RegisterMapErrorを発生させる" do
      invalid_values.each do |invalid_value|
        set_load_data([
          *index_registers,
          [nil, "register_0", "0x08", "[2, 2]", invalid_value, "bit_field_0_0", "[31:0]", "ro", nil]
        ])

        message = "not match number of array dimensions and number of array index fields"
        expect {
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error(message, position("block_0", 8, 4))
      end
    end
  end

  context "配列のサイズが、インデックスフィールドの範囲を超える場合" do
    let(:invalid_values) do
      {5 => "[5, 4]", 6 => "[4, 6]"}
    end

    it "RegisterMapErrorを発生させる" do
      invalid_values.each_with_index do |(array_size, invalid_value), i|
        set_load_data([
          *index_registers,
          [nil, "register_0", "0x08", invalid_value, "index_0, index_1", "bit_field_0_0", "[31:0]", "ro", nil]
        ])

        message = "exceeds maximum array size specified by index_#{i}(4): #{array_size}"
        expect {
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error(message, position("block_0", 8, 4))
      end
    end
  end

  context "指定したインデックス値が、インデックスフィールドの範囲を超える場合" do
    let(:invalid_values) do
      {4 => "index_0: 4", 5 => "index_0: 5"}
    end

    it "RegisterMapErrorを発生させる" do
      invalid_values.each do |index_value, invalid_value|
        set_load_data([
          *index_registers,
          [nil, "register_0", "0x08", nil, invalid_value, "bit_field_0_0", "[31:0]", "ro", nil]
        ])

        message = "exceeds maximum value of index_0(3): #{index_value}"
        expect {
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error(message, position("block_0", 8, 4))
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
        p invalid_value_pair
        set_load_data([
          *index_registers,
          [nil, "register_0", "0x08", invalid_value_pair[0][0], invalid_value_pair[0][1], "bit_field_0_0", "[31:0]", "ro", nil],
          [nil, "register_1", "0x08", invalid_value_pair[1][0], invalid_value_pair[1][1], "bit_field_1_0", "[31:0]", "ro", nil]
        ])

        message = "overlapped shadow indexes"
        expect {
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error(message, position("block_0", 8, 4))
      end
    end
  end
end
