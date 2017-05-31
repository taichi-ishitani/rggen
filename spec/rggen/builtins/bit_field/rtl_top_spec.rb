require_relative '../spec_helper'

describe 'bit_field/rtl_top' do
  include_context 'bit field type common'
  include_context 'configuration common'
  include_context 'rtl common'

  before(:all) do
    enable :global, [:data_width, :address_width]
    enable :register_block, [:name, :byte_size]
    enable :register_block, [:clock_reset, :host_if]
    enable :register_block, :host_if, :apb
    enable :register, [:name, :offset_address, :array, :type]
    enable :register, :rtl_top
    enable :register, :type, :indirect
    enable :bit_field, [:name, :bit_assignment, :type, :initial_value, :reference]
    enable :bit_field, :type, :rw
    enable :bit_field, :rtl_top
  end

  before(:all) do
    configuration = create_configuration(data_width: 32, address_width: 16)
    register_map  = create_register_map(
      configuration,
      "block_0" => [
        [nil, nil, "block_0"                                                                                                                ],
        [nil, nil, 256                                                                                                                      ],
        [nil, nil, nil                                                                                                                      ],
        [nil, nil, nil                                                                                                                      ],
        [nil, "register_0", "0x00"     , nil     , nil                                     , "bit_field_0_0", "[31:16]", "rw", "0xabcd", nil],
        [nil, nil         , nil        , nil     , nil                                     , "bit_field_0_1", "[0]"    , "rw", "1"     , nil],
        [nil, "register_1", "0x04-0x0B", "[2]"   , nil                                     , "bit_field_1_0", "[31:0]" , "rw", "0"     , nil],
        [nil, "register_2", "0x0C"     , "[4, 2]", "indirect: bit_field_0_0, bit_field_0_1", "bit_field_2_0", "[31:0]" , "rw", "0"     , nil]
      ]
    )
    @rtl  = build_rtl_factory.create(configuration, register_map).bit_fields
  end

  let(:rtl) do
    @rtl
  end

  describe "#generate_code" do
    let(:expected_code_0) do
      <<'CODE'
if (1) begin : g_bit_field_0_0
  rggen_bit_field_if #(16) bit_field_sub_if();
  `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 31, 16)
  rggen_bit_field_rw #(
    .WIDTH          (16),
    .INITIAL_VALUE  (16'habcd)
  ) u_bit_field (
    .clk          (clk),
    .rst_n        (rst_n),
    .bit_field_if (bit_field_sub_if),
    .o_value      (o_bit_field_0_0)
  );
end
CODE
    end

    let(:expected_code_1) do
      <<'CODE'
if (1) begin : g_bit_field_0_1
  rggen_bit_field_if #(1) bit_field_sub_if();
  `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 0, 0)
  rggen_bit_field_rw #(
    .WIDTH          (1),
    .INITIAL_VALUE  (1'h1)
  ) u_bit_field (
    .clk          (clk),
    .rst_n        (rst_n),
    .bit_field_if (bit_field_sub_if),
    .o_value      (o_bit_field_0_1)
  );
end
CODE
    end

    let(:expected_code_2) do
        <<'CODE'
if (1) begin : g_bit_field_1_0
  rggen_bit_field_if #(32) bit_field_sub_if();
  `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 31, 0)
  rggen_bit_field_rw #(
    .WIDTH          (32),
    .INITIAL_VALUE  (32'h00000000)
  ) u_bit_field (
    .clk          (clk),
    .rst_n        (rst_n),
    .bit_field_if (bit_field_sub_if),
    .o_value      (o_bit_field_1_0[g_i])
  );
end
CODE
    end

    let(:expected_code_3) do
        <<'CODE'
if (1) begin : g_bit_field_2_0
  rggen_bit_field_if #(32) bit_field_sub_if();
  `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 31, 0)
  rggen_bit_field_rw #(
    .WIDTH          (32),
    .INITIAL_VALUE  (32'h00000000)
  ) u_bit_field (
    .clk          (clk),
    .rst_n        (rst_n),
    .bit_field_if (bit_field_sub_if),
    .o_value      (o_bit_field_2_0[g_i][g_j])
  );
end
CODE
    end

    it "各ビットフィールドのRTLトップのコードを生成する" do
      expect(rtl[0]).to generate_code :register, :top_down, expected_code_0
      expect(rtl[1]).to generate_code :register, :top_down, expected_code_1
      expect(rtl[2]).to generate_code :register, :top_down, expected_code_2
      expect(rtl[3]).to generate_code :register, :top_down, expected_code_3
    end
  end
end
