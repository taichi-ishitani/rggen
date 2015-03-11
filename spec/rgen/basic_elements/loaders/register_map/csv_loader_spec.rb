require_relative 'spec_helper'

describe 'csv_loader' do
  before(:all) do
    RGen.enable(:register_block, :name)
    RGen.enable(:register      , :name)
    RGen.enable(:bit_field     , :name)
    @factory  = RGen.generator.builder.build_factory(:register_map)
  end

  after(:all) do
    clear_enabled_items
  end

  let(:csv_file) do
    File.join(__dir__, 'files', 'sample.csv')
  end

  let(:tsv_file) do
    File.join(__dir__, 'files', 'sample.tsv')
  end

  let(:sheet) do
    'N/A'
  end

  let(:configuration) do
    RGen::Configuration::Configuration.new
  end


  shared_examples_for "loader" do |file_ext|
    let(:register_map) do
      register_map = @factory.create(configuration, file)
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

    it "拡張子が#{file_ext}の#{file_ext.upcase}フォーマットのファイルをロードする" do
      expect(register_blocks).to match([
        have_item(file, sheet, 0, 2, name: 'block_0')
      ])
      expect(registers).to match([
        have_item(file, sheet, 3, 1, name: 'register_0'),
        have_item(file, sheet, 5, 1, name: 'register_1')
      ])
      expect(bit_fields).to match([
        have_item(file, sheet, 3, 2, name: 'bit_field_0_0'),
        have_item(file, sheet, 4, 2, name: 'bit_field_0_1'),
        have_item(file, sheet, 5, 2, name: 'bit_field_1_0')
      ])
    end
  end

  context "入力ファイルの拡張子がcsvのとき" do
    it_should_behave_like 'loader', 'csv' do
      let(:file) do
        csv_file
      end
    end
  end

  context "入力ファイルの拡張子がtsvのとき" do
    it_should_behave_like 'loader', 'tsv' do
      let(:file) do
        tsv_file
      end
    end
  end
end
