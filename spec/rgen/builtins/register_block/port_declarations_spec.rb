require_relative '../spec_helper'

describe "register_block/signal_declarations" do
  include_context 'configuration common'
  include_context 'register_map common'
  include_context 'rtl common'

  before(:all) do
    enable(:global, [:data_width, :address_width])
    enable(:register_block, [:name, :byte_size])
    enable(:register_block, [:port_declarations, :clock_reset, :host_if, :response_mux])
    enable(:register_block, :host_if, :apb)
    enable(:register, :name)
    enable(:bit_field, [:name, :bit_assignment, :type, :initial_value, :reference])
    enable(:bit_field, :type, [:rw, :ro])

    configuration = create_configuration(address_width:16)
    register_map  = create_register_map(
      configuration,
      "block_0" => [
        [nil, nil         , "block_0"                               ],
        [nil, nil         , 256                                     ],
        [                                                           ],
        [                                                           ],
        [nil, "register_0", "bit_field_0_0", "[16]"   , "rw", 0, nil],
        [nil, nil         , "bit_field_0_1", "[0]"    , "ro", 0, nil],
        [nil, "register_1", "bit_field_1_0", "[31:16]", "rw", 0, nil],
        [nil, nil         , "bit_field_1_1", "[15:0]" , "ro", 0, nil]
      ]
    )

    @rtl  = build_rtl_factory.create(configuration, register_map).register_blocks[0]
  end

  after(:all) do
    clear_enabled_items
  end

  let(:rtl) do
    @rtl
  end

  describe "#generate_code" do
    let(:expected_code) do
      <<'CODE'
(
  input clk,
  input rst_n,
  input [15:0] i_paddr,
  input [2:0] i_pprot,
  input i_psel,
  input i_penable,
  input i_pwrite,
  input [31:0] i_pwdata,
  input [3:0] i_pstrb,
  output o_pready,
  output [31:0] o_rdata,
  output o_pslverr,
  output o_bit_field_0_0,
  input i_bit_field_0_1,
  output [15:0] o_bit_field_1_0,
  input [15:0] i_bit_field_1_1
)
CODE
    end

    it "内部信号を宣言するコードを生成する" do
      expect(rtl).to generate_code(:port_declarations, :top_down, expected_code.chomp)
    end
  end
end
