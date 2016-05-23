require_relative 'spec_helper'

describe 'xls_loader' do
  before(:all) do
    RgGen.enable(:register_block, :name)
    RgGen.enable(:register      , :name)
    RgGen.enable(:bit_field     , :name)
    @factory  = RgGen.builder.build_factory(:register_map)
  end

  after(:all) do
    clear_enabled_items
  end

  let(:file) do
    File.join(__dir__, 'files', 'sample.xls')
  end

  let(:configuration) do
    RgGen::InputBase::Component.new(nil)
  end

  let(:register_map) do
    @factory.create(configuration, file)
  end

  let(:register_blocks) do
    register_map.register_blocks
  end

  let(:registers) do
    register_map.registers
  end

  let(:bit_fields) do
    register_map.bit_fields
  end

  it "拡張子がxlsのExcel(2003以前)フォーマットのファイルをロードする" do
    expect(register_blocks).to match([
      have_cell(file, 'sheet_0', 0, 2, name: 'block_0'),
      have_cell(file, 'sheet_2', 0, 2, name: 'block_2')
    ])
    expect(registers).to match([
      have_cell(file, 'sheet_0', 3, 1, name: 'register_0'),
      have_cell(file, 'sheet_0', 5, 1, name: 'register_1'),
      have_cell(file, 'sheet_2', 3, 1, name: 'register_0'),
      have_cell(file, 'sheet_2', 4, 1, name: 'register_1')
    ])
    expect(bit_fields).to match([
      have_cell(file, 'sheet_0', 3, 2, name: 'bit_field_0_0'),
      have_cell(file, 'sheet_0', 4, 2, name: 'bit_field_0_1'),
      have_cell(file, 'sheet_0', 5, 2, name: 'bit_field_1_0'),
      have_cell(file, 'sheet_2', 3, 2, name: 'bit_field_0_0'),
      have_cell(file, 'sheet_2', 4, 2, name: 'bit_field_1_0'),
      have_cell(file, 'sheet_2', 5, 2, name: 'bit_field_1_1')
    ])
  end
end