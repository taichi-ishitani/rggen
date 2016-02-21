require_relative '../spec_helper'

describe "register/address_decoder" do
  include_context 'configuration common'
  include_context 'register_map common'
  include_context 'rtl common'

  before(:all) do
    enable :global, :data_width
    enable :global, :address_width
    enable :register_block, [:name, :byte_size]
    enable :register_block, [:clock_reset, :host_if, :response_mux]
    enable :register_block, :host_if, :apb
    enable :register, [:name, :offset_address, :array, :shadow, :accessibility, :address_decoder]
    enable :bit_field, [:name, :bit_assignment, :type, :initial_value]
    enable :bit_field, :type, [:rw, :ro, :wo, :reserved]

    configuration = create_configuration(host_if: :apb, data_width: 32, address_width: 16)
    register_map  = create_register_map(
      configuration,
      "block_0" => [
        [nil, nil          , "block_0"                                                                                                                                 ],
        [nil, nil          , 256                                                                                                                                       ],
        [nil, nil          , nil                                                                                                                                       ],
        [nil, nil          , nil                                                                                                                                       ],
        [nil, "register_0" , "0x10"      , nil     , nil                                                                 , "bit_field_0_0" , "[31:0]" , "rw"      , "0"],
        [nil, "register_1" , "0x14"      , nil     , nil                                                                 , "bit_field_1_0" , "[31:0]" , "ro"      , "0"],
        [nil, "register_2" , "0x18"      , nil     , nil                                                                 , "bit_field_2_0" , "[31:0]" , "wo"      , "0"],
        [nil, "register_3" , "0x20-0x02F", nil     , nil                                                                 , "bit_field_3_0" , "[31:0]" , "rw"      , "0"],
        [nil, "register_4" , "0x30-0x03F", "[4]"   , nil                                                                 , "bit_field_4_0" , "[31:0]" , "rw"      , "0"],
        [nil, "register_5" , "0x40"      , nil     , "bit_field_10_0:0"                                                  , "bit_field_5_0" , "[31:0]" , "rw"      , "0"],
        [nil, "register_6" , "0x40"      , nil     , "bit_field_10_0:1, bit_field_10_1:2"                                , "bit_field_6_0" , "[31:0]" , "rw"      , "0"],
        [nil, "register_7" , "0x44"      , "[2]"   , "bit_field_10_0"                                                    , "bit_field_7_0" , "[31:0]" , "rw"      , "0"],
        [nil, "register_8" , "0x48"      , "[2, 4]", "bit_field_10_0, bit_field_10_1"                                    , "bit_field_8_0" , "[31:0]" , "rw"      , "0"],
        [nil, "register_9" , "0x4C"      , "[2, 4]", "bit_field_10_0:0, bit_field_10_1, bit_field_10_2:1, bit_field_10_3", "bit_field_9_0" , "[31:0]" , "rw"      , "0"],
        [nil, "register_10", "0x50"      , nil     , nil                                                                 , "bit_field_10_0", "[24]"   , "rw"      , "0"],
        [nil, nil          , nil         , nil     , nil                                                                 , "bit_field_10_1", "[17:16]", "rw"      , "0"],
        [nil, nil          , nil         , nil     , nil                                                                 , "bit_field_10_2", "[11:8]" , "rw"      , "0"],
        [nil, nil          , nil         , nil     , nil                                                                 , "bit_field_10_3", "[7:0]"  , "rw"      , "0"],
        [nil, "register_11", "0x54"      , nil     , nil                                                                 , "bit_field_11_0", "[31:0]" , "reserved", "0"]
      ]
    )

    @rtl  = build_rtl_factory.create(configuration, register_map)
  end

  after(:all) do
    clear_enabled_items
  end

  context "対象レジスタがシャドウレジスタのとき" do
    let(:rtl) do
      @rtl.registers[5..9]
    end

    it "シャドウインデックス用の信号を持つ" do
      expect(rtl[0]).to have_logic(:shadow_index, name: "register_5_shadow_index", width: 1)
      expect(rtl[1]).to have_logic(:shadow_index, name: "register_6_shadow_index", width: 3)
      expect(rtl[2]).to have_logic(:shadow_index, name: "register_7_shadow_index", width: 1 , dimensions: [2])
      expect(rtl[3]).to have_logic(:shadow_index, name: "register_8_shadow_index", width: 3 , dimensions: [2, 4])
      expect(rtl[4]).to have_logic(:shadow_index, name: "register_9_shadow_index", width: 15, dimensions: [2, 4])
    end
  end

  describe "#generate_code" do
    context "レジスタの属性が読み書き可能なとき" do
      let(:expected_code) do
        <<'CODE'
rgen_address_decoder #(
  .READABLE           (1),
  .WRITABLE           (1),
  .ADDRESS_WIDTH      (6),
  .START_ADDRESS      (6'h04),
  .END_ADDRESS        (6'h04),
  .USE_SHADOW_INDEX   (0),
  .SHADOW_INDEX_WIDTH (1),
  .SHADOW_INDEX_VALUE (1'h0)
) u_register_0_address_decoder (
  .i_read         (read),
  .i_write        (write),
  .i_address      (address[7:2]),
  .i_shadow_index (1'h0),
  .o_select       (register_select[0])
);
CODE
      end

      let(:rtl) do
        @rtl.registers[0]
      end

      it "読み書き可能に対応したアドレスデコーダモジュールをインスタンスするコードを出力する" do
        expect(rtl).to generate_code(:module_item, :top_down, expected_code)
      end
    end

    context "レジスタの属性が読み出し可能、書き込み不可なとき" do
      let(:expected_code) do
        <<'CODE'
rgen_address_decoder #(
  .READABLE           (1),
  .WRITABLE           (0),
  .ADDRESS_WIDTH      (6),
  .START_ADDRESS      (6'h05),
  .END_ADDRESS        (6'h05),
  .USE_SHADOW_INDEX   (0),
  .SHADOW_INDEX_WIDTH (1),
  .SHADOW_INDEX_VALUE (1'h0)
) u_register_1_address_decoder (
  .i_read         (read),
  .i_write        (write),
  .i_address      (address[7:2]),
  .i_shadow_index (1'h0),
  .o_select       (register_select[1])
);
CODE
      end

      let(:rtl) do
        @rtl.registers[1]
      end

      it "読み出し可能、書き込み不可に対応したアドレスデコーダモジュールをインスタンスするコードを出力する" do
        expect(rtl).to generate_code(:module_item, :top_down, expected_code)
      end
    end

    context "レジスタの属性が読み出し不可、書き込み可能なとき" do
      let(:expected_code) do
        <<'CODE'
rgen_address_decoder #(
  .READABLE           (0),
  .WRITABLE           (1),
  .ADDRESS_WIDTH      (6),
  .START_ADDRESS      (6'h06),
  .END_ADDRESS        (6'h06),
  .USE_SHADOW_INDEX   (0),
  .SHADOW_INDEX_WIDTH (1),
  .SHADOW_INDEX_VALUE (1'h0)
) u_register_2_address_decoder (
  .i_read         (read),
  .i_write        (write),
  .i_address      (address[7:2]),
  .i_shadow_index (1'h0),
  .o_select       (register_select[2])
);
CODE
      end

      let(:rtl) do
        @rtl.registers[2]
      end

      it "読み出し不可、書き込み可能に対応したアドレスデコーダモジュールをインスタンスするコードを出力する" do
        expect(rtl).to generate_code(:module_item, :top_down, expected_code)
      end
    end

    context "レジスタが複数アドレスにまたがる場合" do
      let(:expected_code) do
        <<'CODE'
rgen_address_decoder #(
  .READABLE           (1),
  .WRITABLE           (1),
  .ADDRESS_WIDTH      (6),
  .START_ADDRESS      (6'h08),
  .END_ADDRESS        (6'h0b),
  .USE_SHADOW_INDEX   (0),
  .SHADOW_INDEX_WIDTH (1),
  .SHADOW_INDEX_VALUE (1'h0)
) u_register_3_address_decoder (
  .i_read         (read),
  .i_write        (write),
  .i_address      (address[7:2]),
  .i_shadow_index (1'h0),
  .o_select       (register_select[3])
);
CODE
      end

      let(:rtl) do
        @rtl.registers[3]
      end

      it "複数アドレスに対応したアドレスデコーダモジュールをインスタンスするコードを出力する" do
        expect(rtl).to generate_code(:module_item, :top_down, expected_code)
      end
    end

    context "対象レジスタが配列になっている場合" do
      let(:expected_code) do
        <<'CODE'
  rgen_address_decoder #(
    .READABLE           (1),
    .WRITABLE           (1),
    .ADDRESS_WIDTH      (6),
    .START_ADDRESS      (6'h0c + g_i),
    .END_ADDRESS        (6'h0c + g_i),
    .USE_SHADOW_INDEX   (0),
    .SHADOW_INDEX_WIDTH (1),
    .SHADOW_INDEX_VALUE (1'h0)
  ) u_register_4_address_decoder (
    .i_read         (read),
    .i_write        (write),
    .i_address      (address[7:2]),
    .i_shadow_index (1'h0),
    .o_select       (register_select[4+g_i])
  );
CODE
      end

      let(:rtl) do
        @rtl.registers[4]
      end

      it "配列レジスタに対応したアドレスデコーダモジュールをインスタンスするコードを出力する" do
        expect(rtl).to generate_code(:module_item, :top_down, expected_code)
      end
    end

    context "対象レジスタがシャドウレジスタの場合" do
      let(:expected_code_0) do
        <<'CODE'
assign register_5_shadow_index = {bit_field_10_0_value};
rgen_address_decoder #(
  .READABLE           (1),
  .WRITABLE           (1),
  .ADDRESS_WIDTH      (6),
  .START_ADDRESS      (6'h10),
  .END_ADDRESS        (6'h10),
  .USE_SHADOW_INDEX   (1),
  .SHADOW_INDEX_WIDTH (1),
  .SHADOW_INDEX_VALUE ({1'h0})
) u_register_5_address_decoder (
  .i_read         (read),
  .i_write        (write),
  .i_address      (address[7:2]),
  .i_shadow_index (register_5_shadow_index),
  .o_select       (register_select[8])
);
CODE
      end

      let(:expected_code_1) do
        <<'CODE'
assign register_6_shadow_index = {bit_field_10_0_value, bit_field_10_1_value};
rgen_address_decoder #(
  .READABLE           (1),
  .WRITABLE           (1),
  .ADDRESS_WIDTH      (6),
  .START_ADDRESS      (6'h10),
  .END_ADDRESS        (6'h10),
  .USE_SHADOW_INDEX   (1),
  .SHADOW_INDEX_WIDTH (3),
  .SHADOW_INDEX_VALUE ({1'h1, 2'h2})
) u_register_6_address_decoder (
  .i_read         (read),
  .i_write        (write),
  .i_address      (address[7:2]),
  .i_shadow_index (register_6_shadow_index),
  .o_select       (register_select[9])
);
CODE
      end

      let(:expected_code_2) do
        <<'CODE'
  assign register_7_shadow_index[g_i] = {bit_field_10_0_value};
  rgen_address_decoder #(
    .READABLE           (1),
    .WRITABLE           (1),
    .ADDRESS_WIDTH      (6),
    .START_ADDRESS      (6'h11),
    .END_ADDRESS        (6'h11),
    .USE_SHADOW_INDEX   (1),
    .SHADOW_INDEX_WIDTH (1),
    .SHADOW_INDEX_VALUE ({g_i[0]})
  ) u_register_7_address_decoder (
    .i_read         (read),
    .i_write        (write),
    .i_address      (address[7:2]),
    .i_shadow_index (register_7_shadow_index[g_i]),
    .o_select       (register_select[10+g_i])
  );
CODE
      end

      let(:expected_code_3) do
        <<'CODE'
    assign register_8_shadow_index[g_i][g_j] = {bit_field_10_0_value, bit_field_10_1_value};
    rgen_address_decoder #(
      .READABLE           (1),
      .WRITABLE           (1),
      .ADDRESS_WIDTH      (6),
      .START_ADDRESS      (6'h12),
      .END_ADDRESS        (6'h12),
      .USE_SHADOW_INDEX   (1),
      .SHADOW_INDEX_WIDTH (3),
      .SHADOW_INDEX_VALUE ({g_i[0], g_j[1:0]})
    ) u_register_8_address_decoder (
      .i_read         (read),
      .i_write        (write),
      .i_address      (address[7:2]),
      .i_shadow_index (register_8_shadow_index[g_i][g_j]),
      .o_select       (register_select[12+4*g_i+g_j])
    );
CODE
      end

      let(:expected_code_4) do
        <<'CODE'
    assign register_9_shadow_index[g_i][g_j] = {bit_field_10_0_value, bit_field_10_1_value, bit_field_10_2_value, bit_field_10_3_value};
    rgen_address_decoder #(
      .READABLE           (1),
      .WRITABLE           (1),
      .ADDRESS_WIDTH      (6),
      .START_ADDRESS      (6'h13),
      .END_ADDRESS        (6'h13),
      .USE_SHADOW_INDEX   (1),
      .SHADOW_INDEX_WIDTH (15),
      .SHADOW_INDEX_VALUE ({1'h0, g_i[1:0], 4'h1, g_j[7:0]})
    ) u_register_9_address_decoder (
      .i_read         (read),
      .i_write        (write),
      .i_address      (address[7:2]),
      .i_shadow_index (register_9_shadow_index[g_i][g_j]),
      .o_select       (register_select[20+4*g_i+g_j])
    );
CODE
      end

      let(:rtl) do
        @rtl.registers[5..9]
      end

      it "シャドウレジスタに対応したアドレスでコーダモジュールをインスタンスするコードを出力する" do
        expect(rtl[0]).to generate_code(:module_item, :top_down, expected_code_0)
        expect(rtl[1]).to generate_code(:module_item, :top_down, expected_code_1)
        expect(rtl[2]).to generate_code(:module_item, :top_down, expected_code_2)
        expect(rtl[3]).to generate_code(:module_item, :top_down, expected_code_3)
        expect(rtl[4]).to generate_code(:module_item, :top_down, expected_code_4)
      end
    end

    context "対象レジスタがリザーブドレジスタの場合" do
      let(:expected_code) do
        <<'CODE'
rgen_address_decoder #(
  .READABLE           (1),
  .WRITABLE           (1),
  .ADDRESS_WIDTH      (6),
  .START_ADDRESS      (6'h15),
  .END_ADDRESS        (6'h15),
  .USE_SHADOW_INDEX   (0),
  .SHADOW_INDEX_WIDTH (1),
  .SHADOW_INDEX_VALUE (1'h0)
) u_register_11_address_decoder (
  .i_read         (read),
  .i_write        (write),
  .i_address      (address[7:2]),
  .i_shadow_index (1'h0),
  .o_select       (register_select[29])
);
CODE
      end

      let(:rtl) do
        @rtl.registers[11]
      end

      it "読み書き可能レジスタとしてアドレスデコーダモジュールをインスタンスするコードを出力する" do
        expect(rtl).to generate_code(:module_item, :top_down, expected_code)
      end
    end
  end
end
