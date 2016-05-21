require_relative '../spec_helper'

describe 'register/external' do
  include_context 'bit field type common'
  include_context 'configuration common'
  include_context 'rtl common'

  before(:all) do
    enable :register_block, [:name, :byte_size]
    enable :register      , [:name, :offset_address, :array, :shadow, :external, :accessibility]
    enable :bit_field     , [:name, :bit_assignment, :type, :initial_value]
    enable :bit_field     , :type, [:rw]
  end

  before(:all) do
    enable :global, [:data_width, :address_width]
    @configuration  = create_configuration
  end

  after(:all) do
    clear_enabled_items
  end

  describe "register_map" do
    before(:all) do
      @factory  = build_register_map_factory
    end

    let(:configuration) do
      @configuration
    end

    let(:factory) do
      @factory
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
          [nil, "register_0", "0x00", nil, nil, nil, "bit_field_0_0", "[0]", "rw", 0],
          [nil, "register_1", "0x04", nil, nil, "" , "bit_field_1_0", "[0]", "rw", 0],
          [nil, "register_2", "0x08", nil, nil, " ", "bit_field_2_0", "[0]", "rw", 0]
        ]
      end

      specify "当該レジスタは内部レジスタである" do
        expect(registers[0]).to be_internal
        expect(registers[1]).to be_internal
        expect(registers[2]).to be_internal
      end

      specify "当該レジスタはビットフィールドを持つ" do
        expect(registers[0].bit_fields).not_to be_empty
        expect(registers[1].bit_fields).not_to be_empty
        expect(registers[2].bit_fields).not_to be_empty
      end
    end

    context "入力がfalseの場合" do
      let(:load_data) do
        [
          [nil, "register_0", "0x00", nil, nil, false   , "bit_field_0_0", "[0]", "rw", 0],
          [nil, "register_1", "0x04", nil, nil, "false" , "bit_field_1_0", "[0]", "rw", 0],
          [nil, "register_2", "0x08", nil, nil, "FALSE" , "bit_field_2_0", "[0]", "rw", 0],
          [nil, "register_3", "0x0C", nil, nil, "fAlSe" , "bit_field_3_0", "[0]", "rw", 0]
        ]
      end

      specify "当該レジスタは内部レジスタである" do
        expect(registers[0]).to be_internal
        expect(registers[1]).to be_internal
        expect(registers[2]).to be_internal
        expect(registers[3]).to be_internal
      end

      specify "当該レジスタはビットフィールドを持つ" do
        expect(registers[0].bit_fields).not_to be_empty
        expect(registers[1].bit_fields).not_to be_empty
        expect(registers[2].bit_fields).not_to be_empty
        expect(registers[3].bit_fields).not_to be_empty
      end
    end

    context "入力がtrueの場合" do
      let(:load_data) do
        [
          [nil, "register_0", "0x00", nil, nil, true  , "bit_field_0_0", "[0]", "rw", 0],
          [nil, "register_1", "0x04", nil, nil, "true", "bit_field_1_0", "[0]", "rw", 0],
          [nil, "register_2", "0x08", nil, nil, "TRUE", "bit_field_2_0", "[0]", "rw", 0],
          [nil, "register_3", "0x0C", nil, nil, "TrUe", "bit_field_3_0", "[0]", "rw", 0]
        ]
      end

      specify "当該レジスタは外部レジスタである" do
        expect(registers[0]).to be_external
        expect(registers[1]).to be_external
        expect(registers[2]).to be_external
        expect(registers[3]).to be_external
      end

      specify "当該レジスタはビットフィールドを持たない" do
        expect(registers[0].bit_fields).to be_empty
        expect(registers[1].bit_fields).to be_empty
        expect(registers[2].bit_fields).to be_empty
        expect(registers[3].bit_fields).to be_empty
      end
    end

    context "入力がtrue, false, nil, 空白でない場合" do
      let(:invalid_values) do
        [1, 0, :foo, "BAR", "NIL"]
      end

      it "RegisterMapErrorを発生させる" do
        invalid_values.each do |invalid_value|
          set_load_data([
            [nil, "register_0", "0x00", nil, nil, invalid_value]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.to raise_register_map_error("invalid value for 'external': #{invalid_value.inspect}", position("block_0", 4, 5))
        end
      end
    end

    context "配列レジスタかつ外部レジスタの場合" do
      it "RegisterMapErrorを発生させる" do
        set_load_data([
          [nil, "register_0", "0x00-0x07", "[2]", nil, true]
        ])
        expect {
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error("not use array/shadow and external register on the same register", position("block_0", 4, 5))
      end
    end

    context "シャドウレジスタかつ外部レジスタの場合" do
      it "RegisterMapErrorを発生させる" do
        set_load_data([
          [nil, "register_0", "0x00", nil, "bit_field_1_0:1", true                                ],
          [nil, "register_1", "0x04", nil, nil              , nil, "bit_field_1_0", "[0]", "rw", 0]
        ])
        expect {
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error("not use array/shadow and external register on the same register", position("block_0", 4, 5))
      end
    end

    context "配列レジスタ、または、シャドウレジスタかつ内部レジスタの場合" do
      it "エラーなく使用できる" do
        set_load_data([
          [nil, "register_0", "0x00", "[2]", "bit_field_1_0", nil, "bit_field_0_0", "[0]", "rw", 0],
          [nil, "register_1", "0x04", nil  , nil            , nil, "bit_field_1_0", "[0]", "rw", 0]
        ])
        expect {
          @factory.create(configuration, register_map_file)
        }.not_to raise_error
      end
    end
  end

  describe "rtl" do
    before(:all) do
      register_map  = create_register_map(
        @configuration,
        "block_0" => [
          [nil, nil         , "block_0"                                                         ],
          [nil, nil         , 256                                                               ],
          [                                                                                     ],
          [                                                                                     ],
          [nil, "register_0", "0x00"     , nil, nil, true, nil            , nil      , nil , nil],
          [nil, "register_1", "0x04"     , nil, nil, nil , "bit_field_1_0", "[31:0]" , "rw", 0  ],
          [nil, "register_2", "0x08-0x0F", nil, nil, true, nil            , nil      , nil , nil],
          [nil, "register_3", "0x10"     , nil, nil, nil , "bit_field_3_0", "[31:0]" , "rw", 0  ],
        ],
        "block_1" => [
          [nil, nil         , "block_1"                                                          ],
          [nil, nil         , 256                                                                ],
          [                                                                                      ],
          [                                                                                      ],
          [nil, "register_0", "0x00"     , "[1]", nil, nil , "bit_field_0_0", "[31:0]", "rw", 0  ],
          [nil, "register_1", "0x04"     , ""   , nil, true, nil            , nil     , nil , nil],
          [nil, "register_2", "0x08-0x0F", "[2]", nil, nil , "bit_field_2_0", "[31:0]", "rw", 0  ],
          [nil, "register_3", "0x20"     , ""   , nil, true, nil            , nil     , nil , nil]
        ]
      )
      @rtl  = build_rtl_factory.create(@configuration, register_map)
    end

    let(:rtl) do
      @rtl.registers
    end

    describe "#external_index" do
      context "内部レジスタの場合" do
        it "nilを返す" do
          expect(rtl[1].external_index).to eq nil
          expect(rtl[3].external_index).to eq nil
          expect(rtl[4].external_index).to eq nil
          expect(rtl[6].external_index).to eq nil
        end
      end

      context "外部レジスタの場合" do
        it "自身が属するレジスタブロック内での外部レジスタインデックスを返す" do
          expect(rtl[0].external_index).to eq 0
          expect(rtl[2].external_index).to eq 1
          expect(rtl[5].external_index).to eq 0
          expect(rtl[7].external_index).to eq 1
        end
      end
    end
  end
end
