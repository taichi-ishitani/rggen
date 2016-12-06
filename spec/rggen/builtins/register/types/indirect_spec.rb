require_relative '../../spec_helper'

describe 'register/types/external' do
  include_context 'register common'
  include_context 'configuration common'

  before(:all) do
    enable :register_block, [:name, :byte_size]
    enable :register, [:name, :offset_address, :array, :type]
    enable :register, :type, :indirect
    enable :bit_field, [:name, :bit_assignment, :type, :initial_value]
    enable :bit_field, :type, [:rw, :ro, :wo, :reserved]
    @factory  = build_register_map_factory
  end

  before(:all) do
    enable :global, [:data_width, :address_width]
    ConfigurationDummyLoader.load_data({})
    @configuration  = build_configuration_factory.create(configuration_file)
  end

  after(:all) do
    clear_enabled_items
  end

  let(:configuration) do
    @configuration
  end

  let(:index_registers) do
    [
      [nil, "index_0", "0x00", nil, nil, "index_0", "[9:8]", "ro", nil],
      [nil, nil      , nil   , nil, nil, "index_1", "[1:0]", "ro", nil],
      [nil, "index_1", "0x04", nil, nil, "index_2", "[9:8]", "ro", nil],
      [nil, nil      , nil   , nil, nil, "index_3", "[1:0]", "ro", nil]
    ]
  end

  let(:indirect_registers) do
    set_load_data_with_index([
      [nil, "register_0" , "0x08", nil        , "indirect: index_0:0"                   , "bit_field_0_0" , "[31:0]", "rw"      , 0  ],
      [nil, "register_1" , "0x08", nil        , "indirect: index_1:0"                   , "bit_field_1_0" , "[31:0]", "wo"      , nil],
      [nil, "register_2" , "0x0c", nil        , "indirect: index_0:0"                   , "bit_field_2_0" , "[31:0]", "ro"      , nil],
      [nil, "register_3" , "0x0c", nil        , "indirect: index_0:1"                   , "bit_field_3_0" , "[31:0]", "reserved", nil],
      [nil, "register_4" , "0x10", nil        , "indirect: index_0:0, index_1:0"        , "bit_field_4_0" , "[31:0]", "ro"      , nil],
      [nil, "register_5" , "0x10", nil        , "indirect: index_0:0 ,index_2:0"        , "bit_field_5_0" , "[31:0]", "ro"      , nil],
      [nil, "register_6" , "0x14", nil        , "indirect: index_0:0\nindex_1:0"        , "bit_field_6_0" , "[31:0]", "ro"      , nil],
      [nil, "register_7" , "0x14", nil        , "indirect: index_0:0\nindex_1:1"        , "bit_field_7_0" , "[31:0]", "ro"      , nil],
      [nil, "register_8" , "0x18", "[4]"      , "indirect: index_0"                     , "bit_field_8_0" , "[31:0]", "ro"      , nil],
      [nil, "register_9" , "0x18", "[2]"      , "indirect: index_1"                     , "bit_field_9_0" , "[31:0]", "ro"      , nil],
      [nil, "register_10", "0x20", "[2, 4]"   , "indirect: index_0, index_1"            , "bit_field_10_0", "[31:0]", "ro"      , nil],
      [nil, "register_11", "0x20", "[2, 4]"   , "indirect: index_0, index_2"            , "bit_field_11_0", "[31:0]", "ro"      , nil],
      [nil, "register_12", "0x24", "[2]"      , "indirect: index_0"                     , "bit_field_12_0", "[31:0]", "ro"      , nil],
      [nil, "register_13", "0x24", "[2, 2, 2]", "indirect: index_1, index_2, index_3"   , "bit_field_13_0", "[31:0]", "ro"      , nil],
      [nil, "register_14", "0x28", "[2, 4]"   , "indirect: index_0, index_1: 0, index_2", "bit_field_14_0", "[31:0]", "ro"      , nil],
      [nil, "register_15", "0x28", "[2, 4]"   , "indirect: index_0, index_1: 1\nindex_2", "bit_field_15_0", "[31:0]", "ro"      , nil]
    ])
    @factory.create(configuration, register_map_file).registers[2..-1]
  end

  def set_load_data_with_index(data)
    set_load_data([*index_registers, *data])
  end

  it "型名は:indirect" do
    expect(indirect_registers).to all(have_attributes(type: :indirect))
  end

  it "配下にビットフィールドを持つ" do
    indirect_registers.each do |indirect_register|
      expect(indirect_register.bit_fields).not_to be_empty
    end
  end

  it "アクセス属性は配下のビットフィールドのアクセス属性による" do
    aggregate_failures do
      expect(indirect_registers[0]).to be_readable
      expect(indirect_registers[0]).to be_writable
      expect(indirect_registers[0]).not_to be_read_only
      expect(indirect_registers[0]).not_to be_write_only
      expect(indirect_registers[0]).not_to be_reserved
    end

    aggregate_failures do
      expect(indirect_registers[1]).not_to be_readable
      expect(indirect_registers[1]).to be_writable
      expect(indirect_registers[1]).not_to be_read_only
      expect(indirect_registers[1]).to be_write_only
      expect(indirect_registers[1]).not_to be_reserved
    end

    aggregate_failures do
      expect(indirect_registers[2]).to be_readable
      expect(indirect_registers[2]).not_to be_writable
      expect(indirect_registers[2]).to be_read_only
      expect(indirect_registers[2]).not_to be_write_only
      expect(indirect_registers[2]).not_to be_reserved
    end

    aggregate_failures do
      expect(indirect_registers[3]).not_to be_readable
      expect(indirect_registers[3]).not_to be_writable
      expect(indirect_registers[3]).not_to be_read_only
      expect(indirect_registers[3]).not_to be_write_only
      expect(indirect_registers[3]).to be_reserved
    end
  end

  it "オプションを必要とする" do
    set_load_data([
      [nil, "register_0" , "0x00", nil, "indirect", "bit_field_0_0" , "[31:0]", "rw", 0  ]
    ])
    expect {
      @factory.create(configuration, register_map_file)
    }.to raise_error RgGen::RegisterMapError
  end

  it "多次元配列に対応する" do
    set_load_data_with_index([
      [nil, "register_0" , "0x00", nil, "indirect: index_0: 1", "bit_field_0_0" , "[31:0]", "rw", 0  ]
    ])
    expect {
      @factory.create(configuration, register_map_file)
    }.not_to raise_error

    set_load_data_with_index([
      [nil, "register_0" , "0x00", "[2]", "indirect: index_0", "bit_field_0_0" , "[31:0]", "rw", 0  ]
    ])
    expect {
      @factory.create(configuration, register_map_file)
    }.not_to raise_error

    set_load_data_with_index([
      [nil, "register_0" , "0x00", "[1, 2]", "indirect: index_0, index_1", "bit_field_0_0" , "[31:0]", "rw", 0  ]
    ])
    expect {
      @factory.create(configuration, register_map_file)
    }.not_to raise_error
  end

  it "必要なバイト幅はデータ幅である" do
    set_load_data_with_index([
      [nil, "register_0" , "0x00 - 0x07", nil, "indirect: index_0: 1", "bit_field_0_0" , "[31:0]", "rw", 0  ]
    ])
    expect {
      @factory.create(configuration, register_map_file)
    }.to raise_error RgGen::RegisterMapError

    set_load_data_with_index([
      [nil, "register_0" , "0x00 - 0x07", "[2]", "indirect: index_0", "bit_field_0_0" , "[31:0]", "rw", 0  ]
    ])
    expect {
      @factory.create(configuration, register_map_file)
    }.to raise_error RgGen::RegisterMapError

    set_load_data_with_index([
      [nil, "register_0" , "0x00 - 0x07", "[1, 2]", "indirect: index_0, index_1", "bit_field_0_0" , "[31:0]", "rw", 0  ]
    ])
    expect {
      @factory.create(configuration, register_map_file)
    }.to raise_error RgGen::RegisterMapError
  end

  describe "#indexes" do
    it "インダイレクトレジスタ用のインデックスを返す" do
      expect(indirect_registers.map(&:indexes).map { |indexes|
        indexes.map(&:values)
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

  context "オプション入力がインデックス設定に適さない場合" do
    let(:invalid_values) do
      ["100", "index_0,,index_1", "index_0, index_1::1"]
    end

    it "RegisterMapErrorを発生させる" do
      invalid_values.each do |invalid_value|
        set_load_data_with_index([
          [nil, "register_0", "0x08", nil, "indirect: #{invalid_value}", "bit_field_0_0", "[31:0]", "ro", nil]
        ])

        message = "invalid value for index: #{invalid_value.inspect}"
        expect {
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error(message, position("block_0", 8, 4))
      end
    end
  end

  context "同一ビットフィールドが2回以上使われた場合" do
    let(:invalid_values) do
      ["index_0, index_0", "index_0:0, index_0:1", "index_0, index_0:0"]
    end

    it "RegisterMapErrorを発生させる" do
      invalid_values.each do |invalid_value|
        set_load_data_with_index([
          [nil, "register_0", "0x0C", nil, "indirect: #{invalid_value}", "bit_field_0_0", "[31:0]", "ro"      , nil]
        ])

        message = "not use the same index field more than once: index_0"
        expect {
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error(message, position("block_0", 8, 4))
      end
    end
  end

  context "指定したインデックスフィールドが存在しないとき" do
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
        set_load_data_with_index([
          [nil, "index_2"   , "0x08", nil, nil                         , "index_4"      , "[31:0]", "reserved", nil],
          [nil, "register_0", "0x0C", nil, "indirect: #{invalid_value}", "bit_field_0_0", "[31:0]", "ro"      , nil]
        ])

        message = "no such index field: #{invalid_field}"
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
        set_load_data_with_index([
          [nil, "register_0", "0x0C", nil, "indirect: #{invalid_value}", "bit_field_0_0", "[31:0]", "ro", nil]
        ])

        message = "not use own bit field for index field: bit_field_0_0"
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
          [nil, "index_0"   , "0x00"     , nil  , nil                         , "index_0"      , "[1:0]" , "ro", nil],
          [nil, "index_1"   , "0x04-0x0B", "[2]", nil                         , "index_1"      , "[1:0]" , "ro", nil],
          [nil, "register_0", "0x0C"     , nil  , "indirect: #{invalid_value}", "bit_field_0_0", "[31:0]", "ro", nil]
        ])

        message = "not use arrayed bit field for index field: index_1"
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
      set_load_data_with_index([
        [nil, "register_0", "0x08", nil, "indirect: #{invalid_value}", "bit_field_0_0", "[31:0]", "ro", nil]
      ])

      message = "not match size of array dimensions and number of array indexes"
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
        set_load_data_with_index([
          [nil, "register_0", "0x08", "[2, 2]", "indirect: #{invalid_value}", "bit_field_0_0", "[31:0]", "ro", nil]
        ])

        message = "not match size of array dimensions and number of array indexes"
        expect {
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error(message, position("block_0", 8, 4))
      end
    end
  end

  context "配列のサイズが、インデックスの範囲を超える場合" do
    let(:invalid_values) do
      {5 => "[5, 4]", 6 => "[4, 6]"}
    end

    it "RegisterMapErrorを発生させる" do
      invalid_values.each_with_index do |(array_size, invalid_value), i|
        set_load_data_with_index([
          [nil, "register_0", "0x08", invalid_value, "indirect: index_0, index_1", "bit_field_0_0", "[31:0]", "ro", nil]
        ])

        message = "array size(#{array_size}) is greater than maximum value of index_#{i}(3)"
        expect {
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error(message, position("block_0", 8, 4))
      end
    end
  end

  context "指定したインデックス値が、インデックの範囲を超える場合" do
    let(:invalid_values) do
      {4 => "index_0: 4", 5 => "index_0: 5"}
    end

    it "RegisterMapErrorを発生させる" do
      invalid_values.each do |index_value, invalid_value|
        set_load_data_with_index([
          [nil, "register_0", "0x08", nil, "indirect: #{invalid_value}", "bit_field_0_0", "[31:0]", "ro", nil]
        ])

        message = "index value(#{index_value}) is greater thatn maximum value of index_0(3)"
        expect {
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error(message, position("block_0", 8, 4))
      end
    end
  end
end
