require_relative '../spec_helper'

describe "register_block/signal_declarations" do
  include_context 'configuration common'
  include_context 'register_map common'
  include_context 'rtl common'

  before(:all) do
    define_list_item(:bit_field, :type, :foo) do
      register_map {read_write}
      rtl do
        build do
          reg  :foo_reg , name: "#{bit_field.name}_reg" , width: bit_field.width
          wire :foo_wire, name: "#{bit_field.name}_wire", width: bit_field.width
        end
      end
    end

    enable(:global, [:data_width, :address_width])
    enable(:register_block, [:name, :byte_size])
    enable(:register_block, [:clock_reset, :signal_declarations, :host_if, :response_mux])
    enable(:register_block, :host_if, :apb)
    enable(:register, :name)
    enable(:bit_field, [:name, :bit_assignment, :type, :initial_value, :reference])
    enable(:bit_field, :type, :foo)

    configuration = create_configuration
    register_map  = create_register_map(
      configuration,
      "block_0" => [
        [nil, nil         , "block_0"                                ],
        [nil, nil         , 256                                      ],
        [                                                            ],
        [                                                            ],
        [nil, "register_0", "bit_field_0_0", "[0]"    , "foo", 0, nil],
        [nil, nil         , "bit_field_0_1", "[31:16]", "foo", 0, nil],
        [nil, "register_1", "bit_field_1_0", "[31:0]" , "foo", 0, nil]
      ]
    )

    @rtl  = build_rtl_factory.create(configuration, register_map).register_blocks[0]
  end

  after(:all) do
    clear_enabled_items
    clear_dummy_list_items(:type, [:foo])
  end

  let(:rtl) do
    @rtl
  end

  describe "#generate_code" do
    let(:expected_code) do
      <<'CODE'
logic command_valid;
logic write;
logic read;
logic [7:0] address;
logic [31:0] write_data;
logic [31:0] write_mask;
logic response_ready;
logic [31:0] read_data;
logic [1:0] status;
logic [1:0] register_select;
logic [31:0] register_read_data[2];
logic bit_field_0_0_value;
reg bit_field_0_0_reg;
wire bit_field_0_0_wire;
logic [15:0] bit_field_0_1_value;
reg [15:0] bit_field_0_1_reg;
wire [15:0] bit_field_0_1_wire;
logic [31:0] bit_field_1_0_value;
reg [31:0] bit_field_1_0_reg;
wire [31:0] bit_field_1_0_wire;
CODE
    end

    it "内部信号を宣言するコードを生成する" do
      expect(rtl).to generate_code(:module_item, :top_down, expected_code)
    end
  end
end
