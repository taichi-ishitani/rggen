require_relative '../spec_helper'

describe 'register/index' do
  include_context 'bit field type common'
  include_context 'configuration common'
  include_context 'rtl common'

  before(:all) do
    enable :global        , [:data_width, :address_width]
    enable :register_block, [:name, :byte_size]
    enable :register      , [:name, :offset_address, :array, :shadow, :accessibility]
    enable :bit_field     , [:name, :bit_assignment, :type, :initial_value]
    enable :bit_field     , :type, [:rw]
    enable :register      , :index

    configuration = create_configuration(data_width: 32, address_width: 16)
    register_map  = create_register_map(
      configuration,
      "block_0" => [
        [nil, nil         , "block_0"                                                                                                   ],
        [nil, nil         , 256                                                                                                         ],
        [                                                                                                                               ],
        [                                                                                                                               ],
        [nil, "register_0", "0x00"     , ""         , nil                                          , "bit_field_0_0", "[31:0]" , "rw", 0],
        [nil, "register_1", "0x04"     , "[1]"      , nil                                          , "bit_field_1_0", "[31:0]" , "rw", 0],
        [nil, "register_2", "0x08-0x0F", "[2]"      , nil                                          , "bit_field_2_0", "[31:0]" , "rw", 0],
        [nil, "register_3", "0x10"     , "[1, 2, 3]", "bit_field_4_0, bit_field_4_1, bit_field_4_2", "bit_field_3_0", "[31:0]" , "rw", 0],
        [nil, "register_4", "0x20"     , ""         , nil                                          , "bit_field_4_0", "[23:16]", "rw", 0],
        [nil, nil         , nil        , nil        , nil                                          , "bit_field_4_1", "[15:8]" , "rw", 0],
        [nil, nil         , nil        , nil        , nil                                          , "bit_field_4_2", "[7:0]"  , "rw", 0]
      ]
    )
    @rtl  = build_rtl_factory.create(configuration, register_map).registers
  end

  after(:all) do
    clear_enabled_items
  end

  let(:rtl) do
    @rtl
  end

  describe "#index" do
    it "自身が属するレジスタブロック内でのインデックスを返す" do
      expect(rtl.map(&:index)).to match [
        0, "1+g_i", "2+g_i", "4+6*g_i+3*g_j+g_k", 10
      ]
    end
  end

  describe "#local_index" do
    context "レジスタが配列では無い場合" do
      it "nilを返す" do
        expect(rtl[0].local_index).to be_nil
        expect(rtl[4].local_index).to be_nil
      end
    end

    context "レジスタが配列の場合" do
      it "generate for文内でのインデックスを返す" do
        expect(rtl[1].local_index).to eq "g_i"
        expect(rtl[2].local_index).to eq "g_i"
        expect(rtl[3].local_index).to eq "6*g_i+3*g_j+g_k"
      end
    end
  end
end
