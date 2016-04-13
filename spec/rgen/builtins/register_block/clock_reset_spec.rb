require_relative '../spec_helper'

describe "register_block/clock_reset" do
  include_context 'configuration common'
  include_context 'register_map common'
  include_context 'rtl common'

  before(:all) do
    RgGen.enable(:register_block, :name       )
    RgGen.enable(:register_block, :clock_reset)
    configuration = dummy_configuration
    register_map  = create_register_map(
      @configuration,
      "block_0" => [
        [nil, nil, "block_0"]
      ]
    )
    @rtl  = build_rtl_factory.create(configuration, register_map)
  end

  after(:all) do
    clear_enabled_items
  end

  it "クロック入力ポートを持つ" do
    expect(@rtl.register_blocks[0]).to have_input(:clock, name: "clk", width:1)
  end

  it "リセット入力ポートを持つ" do
    expect(@rtl.register_blocks[0]).to have_input(:reset, name: "rst_n", width:1)
  end
end
