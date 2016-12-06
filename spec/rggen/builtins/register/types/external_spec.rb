require_relative '../../spec_helper'

describe 'register/types/external' do
  include_context 'register common'
  include_context 'configuration common'

  before(:all) do
    enable :register_block, [:name, :byte_size]
    enable :register, [:name, :offset_address, :array, :type]
    enable :register, :type, :external
    enable :bit_field, [:name, :bit_assignment, :type, :initial_value, :reference]
    enable :bit_field, :type, [:rw, :ro, :wo, :reserved]
    @factory  = build_register_map_factory
  end

  before(:all) do
    enable :global, [:data_width, :address_width]
    ConfigurationDummyLoader.load_data({})
    @configuration  = build_configuration_factory.create(configuration_file)
  end

  after(:all) do
    clear_enabled_items
  end

  let(:configuration) do
    @configuration
  end

  let(:external_register) do
    set_load_data([
      [nil, "register_0", "0x00", nil, :external, "bit_field_0_0", "[0]", :rw, 0, nil]
    ])
    @factory.create(configuration, register_map_file).registers[0]
  end

  it "型名は:external" do
    expect(external_register.type).to eq :external
  end

  it "読み書き可能レジスタ" do
    expect(external_register).to be_readable
    expect(external_register).to be_writable
    expect(external_register).not_to be_read_only
    expect(external_register).not_to be_write_only
    expect(external_register).not_to be_reserved
  end

  it "配列レジスタに対応しない" do
    set_load_data([
      [nil, "register_0", "0x00", "[1]", :external, "bit_field_0_0", "[0]", :rw, 0, nil]
    ])
    expect {
      @factory.create(configuration, register_map_file)
    }.to raise_error RgGen::RegisterMapError

    set_load_data([
      [nil, "register_0", "0x00", "[1, 1]", :external, "bit_field_0_0", "[0]", :rw, 0, nil]
    ])
    expect {
      @factory.create(configuration, register_map_file)
    }.to raise_error RgGen::RegisterMapError
  end

  it "任意のバイト幅で使用できる" do
    set_load_data([
      [nil, "register_0", "0x00"       , nil, :external, "bit_field_0_0", "[0]", :rw, 0, nil],
      [nil, "register_1", "0x04 - 0x0B", nil, :external, "bit_field_1_0", "[0]", :rw, 0, nil]
    ])
    expect {
      @factory.create(configuration, register_map_file)
    }.not_to raise_error
  end

  it "配下にビットフィールドを持たない" do
    expect(external_register.bit_fields).to be_empty
  end
end
