require_relative '../spec_helper'

describe "register_block/irq_controller" do
  include_context 'configuration common'
  include_context 'register_map common'
  include_context 'rtl common'

  before(:all) do
    enable :global, [:data_width, :address_width]
    enable :register_block, [:name, :byte_size]
    enable :register_block, [:clock_reset, :host_if, :irq_controller]
    enable :register_block, :host_if, :apb
    enable :register, [:name, :offset_address, :array, :type]
    enable :register, :type, :indirect
    enable :bit_field, [:name, :bit_assignment, :type, :initial_value, :reference]
    enable :register, :index
    enable :bit_field, :type, [:w0c, :w1c, :rw]

    configuration = create_configuration
    register_map  = create_register_map(
      configuration,
      "block_0" => [
        [nil, nil         , "block_0"                                                         ],
        [nil, nil         , 256                                                               ],
        [                                                                                     ],
        [                                                                                     ],
        [nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[0]", :rw , 0, nil            ],
        [nil, "register_1", "0x04", nil, nil, "bit_field_1_0", "[0]", :w0c, 0, nil            ],
        [nil, "register_2", "0x08", nil, nil, "bit_field_2_0", "[0]", :w1c, 0, nil            ]
      ],
      "block_1" => [
        [nil, nil         , "block_1"                                                         ],
        [nil, nil         , 256                                                               ],
        [                                                                                     ],
        [                                                                                     ],
        [nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[0]", :rw , 0, nil            ],
        [nil, "register_1", "0x04", nil, nil, "bit_field_1_0", "[0]", :w0c, 0, "bit_field_0_0"],
        [nil, "register_2", "0x08", nil, nil, "bit_field_2_0", "[0]", :w1c, 0, nil            ]
      ],
      "block_2" => [
        [nil, nil         , "block_2"                                                         ],
        [nil, nil         , 256                                                               ],
        [                                                                                     ],
        [                                                                                     ],
        [nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[8]", :rw , 0, nil            ],
        [nil, nil         , nil   , nil, nil, "bit_field_0_1", "[0]", :rw , 0, nil            ],
        [nil, "register_1", "0x04", nil, nil, "bit_field_1_0", "[8]", :w0c, 0, "bit_field_0_1"],
        [nil, "register_2", "0x08", nil, nil, "bit_field_2_0", "[0]", :w1c, 0, "bit_field_0_0"]
      ]
    )
    @rtl  = build_rtl_factory.create(configuration, register_map).register_blocks
  end

  after(:all) do
    clear_enabled_items
  end

  context "割り込みビットフィールドを含まない場合" do
    let(:rtl) do
      @rtl[0]
    end

    it "有効なアイテムではない" do
      expect(rtl).not_to have_item :register_block, :rtl, :irq_controller
    end
  end

  context "割り込みビットフィールドを含む場合" do
    let(:rtl) do
      @rtl[1..2]
    end

    it "有効なアイテムである" do
      expect(rtl).to all(have_item(:register_block, :rtl, :irq_controller))
    end

    it "割り込み関連のポート、信号群を持つ" do
      expect(rtl[0]).to have_output :register_block, :irq, width: 1, name: 'o_irq'
      expect(rtl[0]).to have_logic  :register_block, :ier, width: 1
      expect(rtl[0]).to have_logic  :register_block, :isr, width: 1
      expect(rtl[1]).to have_output :register_block, :irq, width: 1, name: 'o_irq'
      expect(rtl[1]).to have_logic  :register_block, :ier, width: 2
      expect(rtl[1]).to have_logic  :register_block, :isr, width: 2
    end

    describe "#generate_code" do
      let(:expected_code_0) do
        <<'CODE'
assign ier = {register_if[0].value[0]};
assign isr = {register_if[1].value[0]};
rggen_irq_controller #(
  .TOTAL_INTERRUPTS (1)
) u_irq_controller (
  .clk    (clk),
  .rst_n  (rst_n),
  .i_ier  (ier),
  .i_isr  (isr),
  .o_irq  (o_irq)
);
CODE
      end

      let(:expected_code_1) do
        <<'CODE'
assign ier = {register_if[0].value[0], register_if[0].value[8]};
assign isr = {register_if[1].value[8], register_if[2].value[0]};
rggen_irq_controller #(
  .TOTAL_INTERRUPTS (2)
) u_irq_controller (
  .clk    (clk),
  .rst_n  (rst_n),
  .i_ier  (ier),
  .i_isr  (isr),
  .o_irq  (o_irq)
);
CODE
      end

      it "割り込み制御モジュールをインスタンスするコードを生成する" do
        expect(rtl[0]).to generate_code :module_item, :top_down, expected_code_0
        expect(rtl[1]).to generate_code :module_item, :top_down, expected_code_1
      end
    end
  end
end
