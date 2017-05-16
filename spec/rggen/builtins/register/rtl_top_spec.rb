require_relative '../spec_helper'

describe 'register/rtl_top' do
  include_context 'register common'
  include_context 'configuration common'
  include_context 'rtl common'

  before(:all) do
    enable :register_block, [:name, :byte_size]
    enable :register      , [:name, :offset_address, :array, :type]
    enable :register      , :type, :indirect
    enable :bit_field     , [:name, :bit_assignment, :type, :initial_value]
    enable :bit_field     , :type, [:rw]
    enable :register_block, [:clock_reset, :host_if]
    enable :register_block, :host_if, :apb
    enable :register      , :rtl_top
  end

  before(:all) do
    enable :global, [:data_width, :address_width]
    @configuration  = create_configuration(data_width: 32, address_width: 16)
  end

  before(:all) do
    @register_map  = create_register_map(
      @configuration,
      "block_0" => [
        [nil, nil         , "block_0"                                                                                                             ],
        [nil, nil         , 256                                                                                                                   ],
        [                                                                                                                                         ],
        [                                                                                                                                         ],
        [nil, "register_0", "0x00"     , ""         , nil                                                    , "bit_field_0_0", "[31:0]" , "rw", 0],
        [nil, "register_1", "0x04"     , "[1]"      , nil                                                    , "bit_field_1_0", "[31:0]" , "rw", 0],
        [nil, "register_2", "0x08-0x0F", "[2]"      , nil                                                    , "bit_field_2_0", "[31:0]" , "rw", 0],
        [nil, "register_3", "0x10"     , "[1, 2, 3]", "indirect: bit_field_4_0, bit_field_4_1, bit_field_4_2", "bit_field_3_0", "[31:0]" , "rw", 0],
        [nil, "register_4", "0x20"     , ""         , nil                                                    , "bit_field_4_0", "[23:16]", "rw", 0],
        [nil, nil         , nil        , nil        , nil                                                    , "bit_field_4_1", "[15:8]" , "rw", 0],
        [nil, nil         , nil        , nil        , nil                                                    , "bit_field_4_2", "[7:0]"  , "rw", 0]
      ],
      "block_1" => [
        [nil, nil         , "block_1"                                                  ],
        [nil, nil         , 256                                                        ],
        [                                                                              ],
        [                                                                              ],
        [nil, "register_0", "0x00"     , "[1]", nil, "bit_field_0_0", "[31:0]", "rw", 0],
        [nil, "register_1", "0x04"     , ""   , nil, "bit_field_1_0", "[31:0]", "rw", 0],
        [nil, "register_2", "0x08-0x0F", "[2]", nil, "bit_field_2_0", "[31:0]", "rw", 0],
        [nil, "register_3", "0x20"     , ""   , nil, "bit_field_3_0", "[31:0]", "rw", 0]
      ]
    )
  end

  before(:all) do
    @rtl  = build_rtl_factory.create(@configuration, @register_map)
  end

  after(:all) do
    clear_enabled_items
  end

  let(:configuration) do
    @configuration
  end

  let(:register_map) do
    @register_map
  end

  let(:rtl) do
    @rtl
  end

  describe "#index" do
    it "自身が属するレジスタブロック内でのインデックスを返す" do
      expect(rtl.register_blocks[0].registers.map(&:index)).to match [
        0, "1+g_i", "2+g_i", "4+6*g_i+3*g_j+g_k", 10
      ]
      expect(rtl.register_blocks[1].registers.map(&:index)).to match [
        "0+g_i", 1, "2+g_i", 4
      ]
    end
  end

  describe "#local_index" do
    context "レジスタが配列では無い場合" do
      it "nilを返す" do
        expect(rtl.registers[0].local_index).to be_nil
        expect(rtl.registers[4].local_index).to be_nil
      end
    end

    context "レジスタが配列の場合" do
      it "generate for文内でのインデックスを返す" do
        expect(rtl.registers[1].local_index).to eq "g_i"
        expect(rtl.registers[2].local_index).to eq "g_i"
        expect(rtl.registers[3].local_index).to eq "6*g_i+3*g_j+g_k"
      end
    end
  end

  describe "#loop_variables" do
    context "レジスタが配列ではない場合" do
      it "nilを返す" do
        expect(rtl.registers[0].loop_variables).to be_nil
        expect(rtl.registers[4].loop_variables).to be_nil
      end
    end

    context "レジスタが配列の場合" do
      it "generate for文のループ変数一覧を返す" do
        expect(rtl.registers[1].loop_variables).to match [match_identifier("g_i")]
        expect(rtl.registers[2].loop_variables).to match [match_identifier("g_i")]
        expect(rtl.registers[3].loop_variables).to match [match_identifier("g_i"), match_identifier("g_j"), match_identifier("g_k")]
      end
    end
  end

  describe "#loop_variable" do
    context "レジスタが配列ではない場合" do
      it "与えたlevelによらずnilを返す" do
        4.times do |level|
          expect(rtl.registers[0].loop_variable(level)).to be_nil
        end
      end
    end

    context "レジスタが配列の場合" do
      it "与えたレベルのgenerate for文用のループ変数を返す" do
        expect(rtl.registers[3].loop_variable(0)).to match_identifier("g_i")
        expect(rtl.registers[3].loop_variable(1)).to match_identifier("g_j")
        expect(rtl.registers[3].loop_variable(2)).to match_identifier("g_k")
        expect(rtl.registers[3].loop_variable(3)).to be_nil
      end
    end
  end

  describe "#generate_code" do
    let(:expected_code_0) do
      <<'CODE'
generate if (1) begin : g_register_0
  rggen_bit_field_if #(32) bit_field_if[1]();
  rggen_default_register #(
    .ADDRESS_WIDTH    (8),
    .START_ADDRESS    (8'h00),
    .END_ADDRESS      (8'h03),
    .DATA_WIDTH       (32),
    .TOTAL_BIT_FIELDS (1),
    .MSB_LIST         ('{31}),
    .LSB_LIST         ('{0})
  ) u_register_0 (
    .register_if  (register_if[0]),
    .bit_field_if (bit_field_if)
  );
  rggen_bit_field_rw #(
    .WIDTH          (32),
    .INITIAL_VALUE  (32'h00000000)
  ) u_bit_field_0_0 (
    .clk          (clk),
    .rst_n        (rst_n),
    .bit_field_if (bit_field_if[0]),
    .o_value      (o_bit_field_0_0)
  );
end endgenerate
CODE
    end

    let(:expected_code_1) do
      <<'CODE'
generate if (1) begin : g_register_2
  genvar g_i;
  for (g_i = 0;g_i < 2;++g_i) begin : g
    rggen_bit_field_if #(32) bit_field_if[1]();
    rggen_default_register #(
      .ADDRESS_WIDTH    (8),
      .START_ADDRESS    (8'h08 + 8'h04 * g_i),
      .END_ADDRESS      (8'h0b + 8'h04 * g_i),
      .DATA_WIDTH       (32),
      .TOTAL_BIT_FIELDS (1),
      .MSB_LIST         ('{31}),
      .LSB_LIST         ('{0})
    ) u_register_2 (
      .register_if  (register_if[2+g_i]),
      .bit_field_if (bit_field_if)
    );
    rggen_bit_field_rw #(
      .WIDTH          (32),
      .INITIAL_VALUE  (32'h00000000)
    ) u_bit_field_2_0 (
      .clk          (clk),
      .rst_n        (rst_n),
      .bit_field_if (bit_field_if[0]),
      .o_value      (o_bit_field_2_0[g_i])
    );
  end
end endgenerate
CODE
    end

    let(:expected_code_2) do
      <<'CODE'
generate if (1) begin : g_register_3
  genvar g_i;
  for (g_i = 0;g_i < 1;++g_i) begin : g
    genvar g_j;
    for (g_j = 0;g_j < 2;++g_j) begin : g
      genvar g_k;
      for (g_k = 0;g_k < 3;++g_k) begin : g
        rggen_bit_field_if #(32) bit_field_if[1]();
        logic [23:0] indirect_index;
        assign indirect_index = {register_if[10].value[23:16], register_if[10].value[15:8], register_if[10].value[7:0]};
        rggen_indirect_register #(
          .ADDRESS_WIDTH    (8),
          .START_ADDRESS    (8'h10),
          .END_ADDRESS      (8'h13),
          .INDEX_WIDTH      (24),
          .INDEX_VALUE      ({g_i[7:0], g_j[7:0], g_k[7:0]}),
          .DATA_WIDTH       (32),
          .TOTAL_BIT_FIELDS (1),
          .MSB_LIST         ('{31}),
          .LSB_LIST         ('{0})
        ) u_register_3 (
          .register_if  (register_if[4+6*g_i+3*g_j+g_k]),
          .bit_field_if (bit_field_if),
          .i_index      (indirect_index)
        );
        rggen_bit_field_rw #(
          .WIDTH          (32),
          .INITIAL_VALUE  (32'h00000000)
        ) u_bit_field_3_0 (
          .clk          (clk),
          .rst_n        (rst_n),
          .bit_field_if (bit_field_if[0]),
          .o_value      (o_bit_field_3_0[g_i][g_j][g_k])
        );
      end
    end
  end
end endgenerate
CODE
    end

    it "各レジスタのRTLトップのコードを生成する" do
      expect(rtl.registers[0]).to generate_code :register_block, :top_down, expected_code_0
      expect(rtl.registers[2]).to generate_code :register_block, :top_down, expected_code_1
      expect(rtl.registers[3]).to generate_code :register_block, :top_down, expected_code_2
    end
  end
end
