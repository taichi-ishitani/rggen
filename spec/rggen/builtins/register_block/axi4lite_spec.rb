require_relative '../spec_helper'

describe 'register_block/axi4lite' do
  include_context 'configuration common'
  include_context 'register_map common'
  include_context 'rtl common'

  before(:all) do
    enable :global, [:address_width, :data_width]
    enable :register_block, [:name, :byte_size, :clock_reset, :host_if]
    enable :register_block, :host_if, :axi4lite
  end

  after(:all) do
    clear_enabled_items
  end

  describe 'configuration' do
    before(:all) do
      @factory  = build_configuration_factory
    end

    let(:factory) do
      @factory
    end

    def configuration(load_data = {})
      ConfigurationDummyLoader.load_data(load_data)
      @factory.create(configuration_file)
    end

    it "axi4lite選択時、データ幅は32, 64ビットのみ選択できる" do
      expect {
        configuration(host_if: :axi4lite, data_width: 32)
      }.not_to raise_error
      expect {
        configuration(host_if: :axi4lite, data_width: 64)
      }.not_to raise_error
      expect {
        configuration(host_if: :axi4lite, data_width: 16)
      }.to raise_configuration_error 'axi4lite supports either 32 or 64 bits data width only: 16'
      expect {
        configuration(host_if: :axi4lite, data_width: 128)
      }.to raise_configuration_error 'axi4lite supports either 32 or 64 bits data width only: 128'
    end
  end

  describe 'rtl' do
    before(:all) do
      configuration = create_configuration(host_if: :axi4lite, data_width: 32, address_width: 16)
      register_map  = create_register_map(
        configuration,
        "block_0" => [
          [nil, nil, "block_0"],
          [nil, nil, 256      ]
        ]
      )
      @rtl  = build_rtl_factory.create(configuration, register_map).register_blocks[0]
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

    it "読み書きの優先度を決めるパラメータを持つ" do
      expect(rtl).to have_parameter(:write_priority, name: 'WRITE_PRIORITY', default: 1)
    end

    it "AXI4LITE用の入出力を持つ" do
      expect(rtl).to  have_input(:axi4lite, :awvalid, name: 'i_awvalid', width: 1                 )
      expect(rtl).to have_output(:axi4lite, :awready, name: 'o_awready', wdith: 1                 )
      expect(rtl).to  have_input(:axi4lite, :awaddr , name: 'i_awaddr' , width: host_address_width)
      expect(rtl).to  have_input(:axi4lite, :awprot , name: 'i_awprot' , width: 3                 )
      expect(rtl).to  have_input(:axi4lite, :wvalid , name: 'i_wvalid' , width: 1                 )
      expect(rtl).to have_output(:axi4lite, :wready , name: 'o_wready' , width: 1                 )
      expect(rtl).to  have_input(:axi4lite, :wdata  , name: 'i_wdata'  , width: data_width        )
      expect(rtl).to  have_input(:axi4lite, :wstrb  , name: 'i_wstrb'  , width: data_width / 8    )
      expect(rtl).to have_output(:axi4lite, :bvalid , name: 'o_bvalid' , width: 1                 )
      expect(rtl).to  have_input(:axi4lite, :bready , name: 'i_bready' , width: 1                 )
      expect(rtl).to have_output(:axi4lite, :bresp  , name: 'o_bresp'  , width: 2                 )
      expect(rtl).to  have_input(:axi4lite, :arvalid, name: 'i_arvalid', width: 1                 )
      expect(rtl).to have_output(:axi4lite, :arready, name: 'o_arready', width: 1                 )
      expect(rtl).to  have_input(:axi4lite, :araddr , name: 'i_araddr' , width: host_address_width)
      expect(rtl).to  have_input(:axi4lite, :arprot , name: 'i_arprot' , width: 3                 )
      expect(rtl).to have_output(:axi4lite, :rvalid , name: 'o_rvalid' , width: 1                 )
      expect(rtl).to  have_input(:axi4lite, :rready , name: 'i_rready' , width: 1                 )
      expect(rtl).to have_output(:axi4lite, :rdata  , name: 'o_rdata'  , width: data_width        )
      expect(rtl).to have_output(:axi4lite, :rresp  , name: 'o_rresp'  , width: 2                 )
    end

    describe "#generate_code" do
      let(:expected_code) do
        <<'CODE'
rggen_host_if_axi4lite #(
  .DATA_WIDTH           (32),
  .HOST_ADDRESS_WIDTH   (16),
  .LOCAL_ADDRESS_WIDTH  (8),
  .WRITE_PRIORITY       (WRITE_PRIORITY)
) u_host_if (
  .clk              (clk),
  .rst_n            (rst_n),
  .i_awvalid        (i_awvalid),
  .o_awready        (o_awready),
  .i_awaddr         (i_awaddr),
  .i_awprot         (i_awprot),
  .i_wvalid         (i_wvalid),
  .o_wready         (o_wready),
  .i_wdata          (i_wdata),
  .i_wstrb          (i_wstrb),
  .o_bvalid         (o_bvalid),
  .i_bready         (i_bready),
  .o_bresp          (o_bresp),
  .i_arvalid        (i_arvalid),
  .o_arready        (o_arready),
  .i_araddr         (i_araddr),
  .i_arprot         (i_arprot),
  .o_rvalid         (o_rvalid),
  .i_rready         (i_rready),
  .o_rdata          (o_rdata),
  .o_rresp          (o_rresp),
  .o_command_valid  (command_valid),
  .o_write          (write),
  .o_read           (read),
  .o_address        (address),
  .o_strobe         (strobe),
  .o_write_data     (write_data),
  .o_write_mask     (write_mask),
  .i_response_ready (response_ready),
  .i_read_data      (read_data),
  .i_status         (status)
);
CODE
      end

      it "AXI4-Lite用のホストIFモジュールをインスタンスするコードを生成する" do
        expect(rtl).to generate_code(:module_item, :top_down, expected_code)
      end
    end
  end
end
