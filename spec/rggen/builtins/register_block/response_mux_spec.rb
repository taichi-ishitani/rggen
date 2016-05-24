require_relative '../spec_helper'

describe "register_block/response_mux" do
  include_context 'configuration common'
  include_context 'register_map common'
  include_context 'rtl common'

  before(:all) do
    enable :global, :data_width
    enable :global, :address_width
    enable :register_block, [:name, :byte_size]
    enable :register_block, [:clock_reset, :host_if, :response_mux]
    enable :register_block, :host_if, :apb
    enable :register, [:name, :offset_address, :array, :shadow, :external]
    enable :bit_field, [:name, :bit_assignment, :type, :initial_value, :reference]
    enable :bit_field, :type, :rw

    configuration = create_configuration(host_if: :apb, data_width: 32, address_width: 16)
    register_map  = create_register_map(
      configuration,
      "block_0" => [
        [nil, nil         , "block_0"                                                                                             ],
        [nil, nil         , 256                                                                                                   ],
        [                                                                                                                         ],
        [                                                                                                                         ],
        [nil, "register_0", "0x00"     , nil    , nil                           , nil , "bit_field_0_0", "[0]"    , "rw", 0  , nil],
        [nil, nil         , nil        , nil    , nil                           , nil , "bit_field_0_1", "[31:16]", "rw", 0  , nil],
        [nil, "register_1", "0x04"     , nil    , nil                           , nil , "bit_field_1_0", "[31:0]" , "rw", 0  , nil],
        [nil, "register_2", "0x08-0x0F", "[2]"  , nil                           , nil , "bit_field_2_0", "[31:0]" , "rw", 0  , nil],
        [nil, "register_3", "0x10"     , "[2,4]", "bit_field_0_0, bit_field_0_1", nil , "bit_field_3_0", "[31:0]" , "rw", 0  , nil]
      ],
      "block_1" => [
        [nil, nil         , "block_1"                                                                                             ],
        [nil, nil         , 256                                                                                                   ],
        [                                                                                                                         ],
        [                                                                                                                         ],
        [nil, "register_0", "0x00"     , nil    , nil                           , nil , "bit_field_0_0", "[0]"    , "rw", 0  , nil],
        [nil, nil         , nil        , nil    , nil                           , nil , "bit_field_0_1", "[31:16]", "rw", 0  , nil],
        [nil, "register_1", "0x04"     , nil    , nil                           , nil , "bit_field_1_0", "[31:0]" , "rw", 0  , nil],
        [nil, "register_2", "0x08-0x0F", "[2]"  , nil                           , nil , "bit_field_2_0", "[31:0]" , "rw", 0  , nil],
        [nil, "register_3", "0x10"     , "[2,4]", "bit_field_0_0, bit_field_0_1", nil , "bit_field_3_0", "[31:0]" , "rw", 0  , nil],
        [nil, "register_4", "0x14"     , nil    , nil                           , true, nil            , nil      , nil , nil, nil],
        [nil, "register_5", "0x18"     , nil    , nil                           , true, nil            , nil      , nil , nil, nil]
      ],
      "block_2" => [
        [nil, nil         , "block_2"                                                                                             ],
        [nil, nil         , 256                                                                                                   ],
        [                                                                                                                         ],
        [                                                                                                                         ],
        [nil, "register_0", "0x00"     , nil    , nil                           , nil , "bit_field_0_0", "[0]"    , "rw", 0  , nil],
        [nil, nil         , nil        , nil    , nil                           , nil , "bit_field_0_1", "[31:16]", "rw", 0  , nil],
        [nil, "register_1", "0x04"     , nil    , nil                           , nil , "bit_field_1_0", "[31:0]" , "rw", 0  , nil],
        [nil, "register_2", "0x08-0x0F", "[2]"  , nil                           , nil , "bit_field_2_0", "[31:0]" , "rw", 0  , nil],
        [nil, "register_3", "0x10"     , "[2,4]", "bit_field_0_0, bit_field_0_1", nil , "bit_field_3_0", "[31:0]" , "rw", 0  , nil],
        [nil, "register_4", "0x14"     , nil    , nil                           , true, nil            , nil      , nil , nil, nil]
      ]
    )

    @rtl  = build_rtl_factory.create(configuration, register_map).register_blocks
  end

  after(:all) do
    clear_enabled_items
  end

  let(:rtl) do
    @rtl
  end

  let(:data_width) do
    32
  end

  let(:total_registers) do
    [12, 14, 13]
  end

  let(:total_external_registers) do
    [2, 1]
  end

  it "レジスタのセレクト信号を持つ" do
    expect(rtl[0]).to have_logic(:register_select, width: total_registers[0])
    expect(rtl[1]).to have_logic(:register_select, width: total_registers[1])
    expect(rtl[2]).to have_logic(:register_select, width: total_registers[2])
  end

  it "各レジスタの読み出しデータを保持する配列信号を持つ" do
    expect(rtl[0]).to have_logic(:register_read_data, width: data_width, dimensions: [total_registers[0]])
    expect(rtl[1]).to have_logic(:register_read_data, width: data_width, dimensions: [total_registers[1]])
    expect(rtl[2]).to have_logic(:register_read_data, width: data_width, dimensions: [total_registers[2]])
  end

  context "外部レジスタを含む場合" do
    it "外部レジスタ用のセレクト信号を持つ" do
      expect(rtl[1]).to have_logic(:external_register_select, width: total_external_registers[0], vector: true)
      expect(rtl[2]).to have_logic(:external_register_select, width: total_external_registers[1], vector: true)
    end

    it "外部レジスタ用のレディ信号を持つ" do
      expect(rtl[1]).to have_logic(:external_register_ready, width: total_external_registers[0], vector: true)
      expect(rtl[2]).to have_logic(:external_register_ready, width: total_external_registers[1], vector: true)
    end

    it "外部レジスタ用のステータス信号を持つ" do
      expect(rtl[1]).to have_logic(:external_register_status, width: 2, dimensions: [total_external_registers[0]])
      expect(rtl[2]).to have_logic(:external_register_status, width: 2, dimensions: [total_external_registers[1]])
    end
  end

  describe "#generate_code" do
    let(:expected_code_0) do
      <<'CODE'
rggen_response_mux #(
  .DATA_WIDTH               (32),
  .TOTAL_REGISTERS          (12),
  .TOTAL_EXTERNAL_REGISTERS (0)
) u_response_mux (
  .clk                        (clk),
  .rst_n                      (rst_n),
  .i_command_valid            (command_valid),
  .i_read                     (read),
  .o_response_ready           (response_ready),
  .o_read_data                (read_data),
  .o_status                   (status),
  .i_register_select          (register_select),
  .i_register_read_data       (register_read_data),
  .i_external_register_select (1'b0),
  .i_external_register_ready  (1'b0),
  .i_external_register_status ('{2'b00})
);
CODE
    end

    let(:expected_code_1) do
      <<'CODE'
rggen_response_mux #(
  .DATA_WIDTH               (32),
  .TOTAL_REGISTERS          (14),
  .TOTAL_EXTERNAL_REGISTERS (2)
) u_response_mux (
  .clk                        (clk),
  .rst_n                      (rst_n),
  .i_command_valid            (command_valid),
  .i_read                     (read),
  .o_response_ready           (response_ready),
  .o_read_data                (read_data),
  .o_status                   (status),
  .i_register_select          (register_select),
  .i_register_read_data       (register_read_data),
  .i_external_register_select (external_register_select),
  .i_external_register_ready  (external_register_ready),
  .i_external_register_status (external_register_status)
);
CODE
    end

    let(:expected_code_2) do
      <<'CODE'
rggen_response_mux #(
  .DATA_WIDTH               (32),
  .TOTAL_REGISTERS          (13),
  .TOTAL_EXTERNAL_REGISTERS (1)
) u_response_mux (
  .clk                        (clk),
  .rst_n                      (rst_n),
  .i_command_valid            (command_valid),
  .i_read                     (read),
  .o_response_ready           (response_ready),
  .o_read_data                (read_data),
  .o_status                   (status),
  .i_register_select          (register_select),
  .i_register_read_data       (register_read_data),
  .i_external_register_select (external_register_select),
  .i_external_register_ready  (external_register_ready),
  .i_external_register_status (external_register_status)
);
CODE
    end

    it "応答マルチプレクサモジュールをインスタンスするコードを出力する" do
      expect(rtl[0]).to generate_code(:module_item, :top_down, expected_code_0)
      expect(rtl[1]).to generate_code(:module_item, :top_down, expected_code_1)
      expect(rtl[2]).to generate_code(:module_item, :top_down, expected_code_2)
    end
  end
end

