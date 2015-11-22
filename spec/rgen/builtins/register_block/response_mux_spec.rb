require_relative '../spec_helper'

describe "register_block/response_mux" do
  include_context 'configuration common'
  include_context 'register_map common'
  include_context 'rtl common'

  before(:all) do
    RGen.enable(:global, :data_width)
    RGen.enable(:global, :address_width)
    RGen.enable(:register_block, [:name, :byte_size])
    RGen.enable(:register_block, [:clock_reset, :host_if, :response_mux])
    RGen.enable(:register_block, :host_if, :apb)
    RGen.enable(:register, :name)

    configuration = create_configuration(host_if: :apb, data_width: 32, address_width: 16)
    register_map  = create_register_map(
      configuration,
      "block_0" => [
        [nil, nil         , "block_0"],
        [nil, nil         , 256      ],
        [nil, nil         , nil      ],
        [nil, nil         , nil      ],
        [nil, "register_0", nil      ],
        [nil, "register_1", nil      ],
        [nil, "register_2", nil      ],
        [nil, "register_3", nil      ]
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

  let(:total_registers) do
    4
  end

  it "レジスタのセレクト信号を持つ" do
    expect(rtl).to have_logic(:register_select, width: total_registers)
  end

  it "各レジスタの読み出しデータを保持する配列信号を持つ" do
    expect(rtl).to have_logic(:register_read_data, width: data_width, dimension: total_registers)
  end

  describe "#generate_code" do
    let(:expected_code) do
      <<'CODE'
rgen_response_mux #(
  .DATA_WIDTH       (32),
  .TOTAL_REGISTERS  (4)
) u_response_mux (
  .clk                  (clk),
  .rst_n                (rst_n),
  .o_response_ready     (response_ready),
  .o_read_data          (read_data),
  .o_status             (status),
  .i_register_select    (register_select),
  .i_register_read_data (register_read_data)
);
CODE
    end

    it "応答マルチプレクサモジュールをインスタンスするコードを出力する" do
      expect(rtl).to generate_code(:module_item, :top_down, expected_code)
    end
  end
end

