require_relative '../spec_helper'

describe "register/address_decoder" do
  include_context 'configuration common'
  include_context 'register_map common'
  include_context 'rtl common'

  before(:all) do
    RGen.enable(:global, :data_width)
    RGen.enable(:global, :address_width)
    RGen.enable(:register_block, [:name, :byte_size])
    RGen.enable(:register_block, [:clock_reset, :host_if, :response_mux])
    RGen.enable(:register_block, :host_if, :apb)
    RGen.enable(:register, [:name, :offset_address, :accessibility, :address_decoder, :index])
    RGen.enable(:bit_field, [:name, :bit_assignment, :type, :initial_value])
    RGen.enable(:bit_field, :type, [:rw, :ro, :wo])

    configuration = create_configuration(host_if: :apb, data_width: 32, address_width: 16)
    register_map  = create_register_map(
      configuration,
      "block_0" => [
        [nil, nil         , "block_0"                                         ],
        [nil, nil         , 256                                               ],
        [nil, nil         , nil                                               ],
        [nil, nil         , nil                                               ],
        [nil, "register_0", "0x10"      , "bit_field_0_0", "[31:0]", "rw", '0'],
        [nil, "register_1", "0x14"      , "bit_field_1_0", "[31:0]", "ro", '0'],
        [nil, "register_2", "0x18"      , "bit_field_2_0", "[31:0]", "wo", '0'],
        [nil, "register_3", "0x20-0x02F", "bit_field_3_0", "[31:0]", "rw", '0']
      ]
    )

    @rtl  = build_rtl_factory.create(configuration, register_map)
  end

  after(:all) do
    clear_enabled_items
  end

  describe "#create_code" do
    context "レジスタの属性が読み書き可能なとき" do
      let(:expected_code) do
        <<'CODE'
rgen_address_decoder #(
  .ADDRESS_WIDTH  (6),
  .READABLE       (1),
  .WRITABLE       (1),
  .START_ADDRESS  (6'h04),
  .END_ADDRESS    (6'h04)
) u_register_0_address_decoder (
  .i_address  (address[7:2]),
  .i_read     (read),
  .i_write    (write),
  .o_select   (register_select[0])
);
CODE
      end

      let(:rtl) do
        @rtl.registers[0]
      end

      it "読み書き可能に対応したアドレスでコーダモジュールをインスタンスするコードを出力する" do
        expect(rtl).to generate_code(:module_item, :top_down, expected_code)
      end
    end

    context "レジスタの属性が読み出し可能、書き込み不可なとき" do
      let(:expected_code) do
        <<'CODE'
rgen_address_decoder #(
  .ADDRESS_WIDTH  (6),
  .READABLE       (1),
  .WRITABLE       (0),
  .START_ADDRESS  (6'h05),
  .END_ADDRESS    (6'h05)
) u_register_1_address_decoder (
  .i_address  (address[7:2]),
  .i_read     (read),
  .i_write    (write),
  .o_select   (register_select[1])
);
CODE
      end

      let(:rtl) do
        @rtl.registers[1]
      end

      it "読み出し可能、書き込み不可に対応したアドレスでコーダモジュールをインスタンスするコードを出力する" do
        expect(rtl).to generate_code(:module_item, :top_down, expected_code)
      end
    end

    context "レジスタの属性が読み出し不可、書き込み可能なとき" do
      let(:expected_code) do
        <<'CODE'
rgen_address_decoder #(
  .ADDRESS_WIDTH  (6),
  .READABLE       (0),
  .WRITABLE       (1),
  .START_ADDRESS  (6'h06),
  .END_ADDRESS    (6'h06)
) u_register_2_address_decoder (
  .i_address  (address[7:2]),
  .i_read     (read),
  .i_write    (write),
  .o_select   (register_select[2])
);
CODE
      end

      let(:rtl) do
        @rtl.registers[2]
      end

      it "読み出し不可、書き込み可能に対応したアドレスでコーダモジュールをインスタンスするコードを出力する" do
        expect(rtl).to generate_code(:module_item, :top_down, expected_code)
      end
    end

    context "レジスタが複数アドレスにまたがる場合" do
      let(:expected_code) do
        <<'CODE'
rgen_address_decoder #(
  .ADDRESS_WIDTH  (6),
  .READABLE       (1),
  .WRITABLE       (1),
  .START_ADDRESS  (6'h08),
  .END_ADDRESS    (6'h0b)
) u_register_3_address_decoder (
  .i_address  (address[7:2]),
  .i_read     (read),
  .i_write    (write),
  .o_select   (register_select[3])
);
CODE
      end

      let(:rtl) do
        @rtl.registers[3]
      end

      it "複数アドレスに対応したアドレスでコーダモジュールをインスタンスするコードを出力する" do
        expect(rtl).to generate_code(:module_item, :top_down, expected_code)
      end
    end
  end
end
