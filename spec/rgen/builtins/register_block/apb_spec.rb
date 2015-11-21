require_relative '../spec_helper'

describe "register_block/apb" do
  include_context 'configuration common'
  include_context 'register_map common'
  include_context 'rtl common'

  before(:all) do
    RGen.enable(:global, :address_width)
    RGen.enable(:global, :data_width   )
    RGen.enable(:register_block, :name       )
    RGen.enable(:register_block, :byte_size  )
    RGen.enable(:register_block, :clock_reset)
    RGen.enable(:register_block, :host_if    )
    RGen.enable(:register_block, :host_if, [:apb])

    configuration = create_configuration(host_if: :apb, data_width: 32, address_width: 16)
    register_map  = create_register_map(
      configuration,
      "block_0" => [
        [nil, nil, "block_0"],
        [nil, nil, 256      ]
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

  let(:data_width) do
    32
  end

  let(:host_address_width) do
    16
  end

  it "APB用の入出出力を持つ" do
    expect(rtl).to  have_input(:apb, :paddr  , name: "i_paddr"  , width: host_address_width)
    expect(rtl).to  have_input(:apb, :pprot  , name: "i_pprot"  , width: 3                 )
    expect(rtl).to  have_input(:apb, :psel   , name: "i_psel"   , width: 1                 )
    expect(rtl).to  have_input(:apb, :penable, name: "i_penable", width: 1                 )
    expect(rtl).to  have_input(:apb, :pwrite , name: "i_pwrite" , width: 1                 )
    expect(rtl).to  have_input(:apb, :pwdata , name: "i_pwdata" , width: data_width        )
    expect(rtl).to  have_input(:apb, :pstrb  , name: "i_pstrb"  , width: data_width / 8    )
    expect(rtl).to have_output(:apb, :pready , name: "o_pready" , width: 1                 )
    expect(rtl).to have_output(:apb, :prdata , name: "o_prdata" , width: data_width        )
    expect(rtl).to have_output(:apb, :pslverr, name: "o_pslverr", width: 1                 )
  end

  describe "#generate_code" do
    let(:expected_code) do
      <<'CODE'
rgen_host_if_apb #(
  .DATA_WIDTH           (32),
  .HOST_ADDRESS_WIDTH   (16),
  .LOCAL_ADDRESS_WIDTH  (8)
) u_host_if (
  .clk              (clk),
  .rst_n            (rst_n),
  .i_paddr          (i_paddr),
  .i_pprot          (i_pprot),
  .i_penable        (i_penable),
  .i_pwrite         (i_pwrite),
  .i_pwdata         (i_pwdata),
  .i_pstrb          (i_pstrb),
  .o_pready         (o_pready),
  .o_prdata         (o_prdata),
  .o_pslverr        (o_pslverr),
  .o_command_valid  (command_valid),
  .o_write          (write),
  .o_read           (read),
  .o_address        (address),
  .o_write_data     (write_data),
  .o_write_mask     (write_mask),
  .i_response_ready (response_ready),
  .i_read_data      (read_data),
  .i_status         (status)
);
CODE
    end

    it "APB用のホストIFモジュールをインスタンスするコードを出力する" do
      expect(rtl).to generate_code(:module_item, :top_down, expected_code)
    end
  end
end
