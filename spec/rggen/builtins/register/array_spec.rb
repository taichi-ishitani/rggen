require_relative '../spec_helper'

describe 'register/array' do
  include_context 'register common'
  include_context 'configuration common'
  include_context 'rtl common'

  before(:all) do
    enable :register_block, [:name, :byte_size]
    enable :register      , [:name, :offset_address, :array, :type]
    enable :register      , :type, :indirect
    enable :bit_field     , [:name, :bit_assignment, :type, :initial_value]
    enable :bit_field     , :type, [:rw]
    enable :register_block, [:clock_reset, :host_if, :response_mux]
    enable :register_block, :host_if, :apb
    enable :register      , :address_decoder
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

    context "入力がnilや空文字の場合" do
      let(:load_data) do
        [
          [nil, "register_0", "0x00"     , nil, nil, "bit_field_0_0", "[31:0]", "rw", 0],
          [nil, "register_1", "0x04-0x0B", "" , nil, "bit_field_1_0", "[31:0]", "rw", 0]
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

      describe "#count" do
        it "1を返す" do
          expect(registers.map(&:count)).to all(eq(1))
        end
      end
    end

    context "適切な入力が与えられた場合" do
      let(:load_data) do
        [
          [nil, "register_0", "0x00"     , "[ 1]"     , nil                                  , "bit_field_0_0", "[31:0]" , "rw", 0],
          [nil, "register_1", "0x04-0x0B", "[2 ]"     , nil                                  , "bit_field_1_0", "[31:0]" , "rw", 0],
          [nil, "register_2", "0x20-0x47", "[10]"     , nil                                  , "bit_field_2_0", "[31:0]" , "rw", 0],
          [nil, "register_3", "0x50"     , "[2, 3, 4]", "indirect: index_0, index_1, index_2", "bit_field_3_0", "[31:0]" , "rw", 0],
          [nil, "regsiter_4", "0x54"     , nil        , nil                                  , "index_0"      , "[17:16]", "rw", 0],
          [nil, nil         , nil        , nil        , nil                                  , "index_1"      , "[ 9: 8]", "rw", 0],
          [nil, nil         , nil        , nil        , nil                                  , "index_2"      , "[ 1: 0]", "rw", 0]
        ]
      end

      describe "#array?" do
        it "真を返す" do
          expect(registers.first(4).map(&:array?)).to all(be_truthy)
        end
      end

      describe "#dimensions" do
        it "次元を配列で返す" do
          expect(registers.first(4).map(&:dimensions)).to match([
            [1], [2], [10], [2, 3, 4]
          ])
        end
      end

      describe "#count" do
        it "含まれるレジスタの総数を返す" do
          expect(registers.first(4).map(&:count)).to match([
            1, 2, 10, 24
          ])
        end
      end
    end

    context "入力が配列設定に適さないとき" do
      let(:invalid_values) do
        ["[-1]", "[01]", "[1.0]", "[1", "1]", "1", "[\n1]", "foo"]
      end

      it "RegisterMapErrorを発生させる" do
        invalid_values.each do |invalid_value|
          set_load_data([
            [nil, "register_0", "0x00", invalid_value, nil, "bit_field_0_0", "[31:0]", "rw", 0]
          ])

          message = "invalid value for array dimension: #{invalid_value.inspect}"
          expect {
            @factory.create(configuration, register_map_file)
          }.to raise_register_map_error(message, position("block_0", 4, 3))
        end
      end
    end

    context "実レジスタに対して、複数次元を持つ配列を設定したとき" do
      let(:invalid_value) do
        "[2, 2]"
      end

      it "RegisterMapErrorを発生させる" do
        set_load_data([
          [nil, "register_0", "0x00 - 0x0F", invalid_value, nil, "bit_field_0_0", "[31:0]", "rw", 0]
        ])

        message = "not use multi dimensions array with real register"
        expect {
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error(message, position("block_0", 4, 3))
      end
    end

    context "配列の大きさに0が設定されたとき" do
      let(:invalid_value) do
        "[0]"
      end

      it do
        set_load_data([
          [nil, "register_0", "0x00", invalid_value, nil, "bit_field_0_0", "[31:0]", "rw", 0]
        ])

        message = "0 is not allowed for array dimension: #{invalid_value.inspect}"
        expect {
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error(message, position("block_0", 4, 3))
      end
    end

    context "配列の大きさと自身のバイトサイズが合わないとき" do
      let(:invalid_values) do
        [1, 3]
      end

      it "RegisterMapErrorを発生させる" do
        invalid_values.each do |invalid_value|
          set_load_data([
            [nil, "register_0", "0x00-0x07", "[#{invalid_value}]", nil, "bit_field_0_0", "[31:0]", "rw", 0]
          ])

          message = "mismatches with own byte size(8): #{[invalid_value]}"
          expect {
            @factory.create(configuration, register_map_file)
          }.to raise_register_map_error(message, position("block_0", 4, 3))
        end
      end
    end
  end

  describe "rtl" do
    before(:all) do
      register_map  = create_register_map(
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
      @rtl  = build_rtl_factory.create(@configuration, register_map)
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
      context "レジスタが配列では無い場合" do
        let(:expected_code) do
          <<'CODE'
rggen_address_decoder #(
  .ADDRESS_WIDTH        (6),
  .START_ADDRESS        (6'h00),
  .END_ADDRESS          (6'h00),
  .INDIRECT_REGISTER    (0),
  .INDIRECT_INDEX_WIDTH (1),
  .INDIRECT_INDEX_VALUE (1'h0)
) u_register_0_address_decoder (
  .i_address        (address[7:2]),
  .i_indirect_index (1'h0),
  .o_select         (register_select[0])
);
assign o_bit_field_0_0 = bit_field_0_0_value;
rggen_bit_field_rw #(
  .WIDTH          (32),
  .INITIAL_VALUE  (32'h00000000)
) u_bit_field_0_0 (
  .clk              (clk),
  .rst_n            (rst_n),
  .i_command_valid  (command_valid),
  .i_select         (register_select[0]),
  .i_write          (write),
  .i_write_data     (write_data[31:0]),
  .i_write_mask     (write_mask[31:0]),
  .o_value          (bit_field_0_0_value)
);
CODE
        end

        it "そのままコードを出力する" do
          expect(rtl.registers[0]).to generate_code(:module_item, :top_down, expected_code)
        end
      end

      context "レジスタが配列の場合" do
        let(:expected_code_0) do
          <<'CODE'
generate if (1) begin : g_register_2
  genvar g_i;
  for (g_i = 0;g_i < 2;g_i++) begin : g
    rggen_address_decoder #(
      .ADDRESS_WIDTH        (6),
      .START_ADDRESS        (6'h02 + g_i),
      .END_ADDRESS          (6'h02 + g_i),
      .INDIRECT_REGISTER    (0),
      .INDIRECT_INDEX_WIDTH (1),
      .INDIRECT_INDEX_VALUE (1'h0)
    ) u_register_2_address_decoder (
      .i_address        (address[7:2]),
      .i_indirect_index (1'h0),
      .o_select         (register_select[2+g_i])
    );
    assign o_bit_field_2_0[g_i] = bit_field_2_0_value[g_i];
    rggen_bit_field_rw #(
      .WIDTH          (32),
      .INITIAL_VALUE  (32'h00000000)
    ) u_bit_field_2_0 (
      .clk              (clk),
      .rst_n            (rst_n),
      .i_command_valid  (command_valid),
      .i_select         (register_select[2+g_i]),
      .i_write          (write),
      .i_write_data     (write_data[31:0]),
      .i_write_mask     (write_mask[31:0]),
      .o_value          (bit_field_2_0_value[g_i])
    );
  end
end endgenerate
CODE
        end

        let(:expected_code_1) do
          <<'CODE'
generate if (1) begin : g_register_3
  genvar g_i, g_j, g_k;
  for (g_i = 0;g_i < 1;g_i++) begin : g
    for (g_j = 0;g_j < 2;g_j++) begin : g
      for (g_k = 0;g_k < 3;g_k++) begin : g
        assign register_3_indirect_index[g_i][g_j][g_k] = {bit_field_4_0_value, bit_field_4_1_value, bit_field_4_2_value};
        rggen_address_decoder #(
          .ADDRESS_WIDTH        (6),
          .START_ADDRESS        (6'h04),
          .END_ADDRESS          (6'h04),
          .INDIRECT_REGISTER    (1),
          .INDIRECT_INDEX_WIDTH (24),
          .INDIRECT_INDEX_VALUE ({g_i[7:0], g_j[7:0], g_k[7:0]})
        ) u_register_3_address_decoder (
          .i_address        (address[7:2]),
          .i_indirect_index (register_3_indirect_index[g_i][g_j][g_k]),
          .o_select         (register_select[4+6*g_i+3*g_j+g_k])
        );
        assign o_bit_field_3_0[g_i][g_j][g_k] = bit_field_3_0_value[g_i][g_j][g_k];
        rggen_bit_field_rw #(
          .WIDTH          (32),
          .INITIAL_VALUE  (32'h00000000)
        ) u_bit_field_3_0 (
          .clk              (clk),
          .rst_n            (rst_n),
          .i_command_valid  (command_valid),
          .i_select         (register_select[4+6*g_i+3*g_j+g_k]),
          .i_write          (write),
          .i_write_data     (write_data[31:0]),
          .i_write_mask     (write_mask[31:0]),
          .o_value          (bit_field_3_0_value[g_i][g_j][g_k])
        );
      end
    end
  end
end endgenerate
CODE
        end

        it "generate for文で包んだコードを出力する" do
          expect(rtl.registers[2]).to generate_code(:module_item, :top_down, expected_code_0)
          expect(rtl.registers[3]).to generate_code(:module_item, :top_down, expected_code_1)
        end
      end
    end
  end
end
