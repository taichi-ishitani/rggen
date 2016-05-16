require_relative '../spec_helper'

describe 'register/accessibility' do
  include_context 'bit field type common'
  include_context 'configuration common'

  before(:all) do
    enable :register_block, [:name, :byte_size]
    enable :register      , [:name, :offset_address, :array, :shadow, :external, :accessibility]
    enable :bit_field     , [:name, :bit_assignment, :type, :initial_value, :reference]
    enable :bit_field     , :type, [:rw, :ro, :wo, :reserved]
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

  let(:registers) do
    set_load_data(load_data)
    @factory.create(configuration, register_map_file).registers
  end

  describe "#readable?" do
    context "読み出し可能なビットフィールドが1つ以上含まれる場合" do
      let(:load_data) do
        [
          [nil, "registers_0", "0x00", nil, nil, nil, "bit_field_0_0", "[0]", "rw"      , 0  , nil],
          [nil, "registers_1", "0x04", nil, nil, nil, "bit_field_1_0", "[0]", "ro"      , nil, nil],
          [nil, "registers_2", "0x08", nil, nil, nil, "bit_field_2_0", "[1]", "rw"      , 1  , nil],
          [nil, nil          , nil   , nil, nil, nil, "bit_field_2_1", "[0]", "reserved", nil, nil],
          [nil, "registers_3", "0x0C", nil, nil, nil, "bit_field_3_0", "[1]", "wo"      , nil, nil],
          [nil, nil          , nil   , nil, nil, nil, "bit_field_3_1", "[0]", "ro"      , nil, nil]
        ]
      end

      it "真を返す" do
        registers.each do |register|
          expect(register).to be_readable
        end
      end
    end

    context "読み出し可能なビットフィールドが含まれない場合" do
      let(:load_data) do
        [
          [nil, "registers_0", "0x00", nil, nil, nil, "bit_field_0_0", "[0]", "wo"      , nil, nil],
          [nil, "registers_1", "0x04", nil, nil, nil, "bit_field_1_0", "[0]", "reserved", nil, nil],
          [nil, "registers_2", "0x08", nil, nil, nil, "bit_field_2_0", "[1]", "reserved", nil, nil],
          [nil, nil          , nil   , nil, nil, nil, "bit_field_2_1", "[0]", "wo"      , nil, nil]
        ]
      end

      it "偽を返す" do
        registers.each do |register|
          expect(register).not_to be_readable
        end
      end
    end

    context "外部レジスタの場合" do
      let(:load_data) do
        [
          [nil, "register_0", "0x00", nil, nil, true]
        ]
      end

      it "真を返す" do
        expect(registers[0]).to be_readable
      end
    end
  end

  describe "#writable?" do
    context "書き込み可能なビットフィールドが1つ以上含まれる場合" do
      let(:load_data) do
        [
          [nil, "registers_0", "0x00", nil, nil, nil, "bit_field_0_0", "[0]", "rw"      , 0  , nil],
          [nil, "registers_1", "0x04", nil, nil, nil, "bit_field_1_0", "[0]", "wo"      , nil, nil],
          [nil, "registers_2", "0x08", nil, nil, nil, "bit_field_2_0", "[1]", "rw"      , 0  , nil],
          [nil, nil          , nil   , nil, nil, nil, "bit_field_2_1", "[0]", "reserved", nil, nil],
          [nil, "registers_3", "0x0C", nil, nil, nil, "bit_field_3_0", "[1]", "wo"      , nil, nil],
          [nil, nil          , nil   , nil, nil, nil, "bit_field_3_1", "[0]", "ro"      , nil, nil]
        ]
      end

      it "真を返す" do
        registers.each do |register|
          expect(register).to be_writable
        end
      end
    end

    context "書き込み可能なビットフィールドが含まれない場合" do
      let(:load_data) do
        [
          [nil, "registers_0", "0x00", nil, nil, nil, "bit_field_0_0", "[0]", "ro"      , nil, nil],
          [nil, "registers_1", "0x00", nil, nil, nil, "bit_field_1_0", "[0]", "reserved", nil, nil],
          [nil, "registers_2", "0x00", nil, nil, nil, "bit_field_2_0", "[1]", "reserved", nil, nil],
          [nil, nil          , nil   , nil, nil, nil, "bit_field_2_1", "[0]", "ro"      , nil, nil]
        ]
      end

      it "偽を返す" do
        registers.each do |register|
          expect(register).not_to be_writable
        end
      end
    end

    context "外部レジスタの場合" do
      let(:load_data) do
        [
          [nil, "register_0", "0x00", nil, nil, true]
        ]
      end

      it "真を返す" do
        expect(registers[0]).to be_writable
      end
    end
  end

  describe "#read_only?" do
    context "読み出し可能かつ書き込み可能なビットフィールドが含まれない場合" do
      let(:load_data) do
        [
          [nil, "registers_0", "0x00", nil, nil, nil, "bit_field_0_0", "[0]", "ro"      , nil, nil],
          [nil, "registers_1", "0x04", nil, nil, nil, "bit_field_1_0", "[1]", "ro"      , nil, nil],
          [nil, nil          , nil   , nil, nil, nil, "bit_field_1_1", "[0]", "ro"      , nil, nil],
          [nil, "registers_2", "0x08", nil, nil, nil, "bit_field_2_0", "[1]", "reserved", nil, nil],
          [nil, nil          , nil   , nil, nil, nil, "bit_field_2_1", "[0]", "ro"      , nil, nil]
        ]
      end

      it "真を返す" do
        registers.each do |register|
          expect(register).to be_read_only
        end
      end
    end

    context "書き込み可能なビットフィールドが含まれる場合" do
      let(:load_data) do
        [
          [nil, "registers_0", "0x00", nil, nil, nil, "bit_field_0_0", "[1]", "ro", nil, nil],
          [nil, nil          , nil   , nil, nil, nil, "bit_field_0_1", "[0]", "rw", 0  , nil],
          [nil, "registers_1", "0x04", nil, nil, nil, "bit_field_1_0", "[1]", "ro", nil, nil],
          [nil, nil          , nil   , nil, nil, nil, "bit_field_1_1", "[0]", "wo", nil, nil]
        ]
      end

      it "偽を返す" do
        registers.each do |register|
          expect(register).not_to be_read_only
        end
      end
    end

    context "読み出し可能なビットフィールドが含まれない場合" do
      let(:load_data) do
        [
          [nil, "registers_0", "0x00", nil, nil, nil, "bit_field_0_0", "[0]", "wo"      , nil, nil],
          [nil, "registers_1", "0x04", nil, nil, nil, "bit_field_1_0", "[0]", "reserved", nil, nil],
          [nil, "registers_2", "0x08", nil, nil, nil, "bit_field_2_0", "[1]", "reserved", nil, nil],
          [nil, nil          , nil   , nil, nil, nil, "bit_field_2_1", "[0]", "wo"      , nil, nil]
        ]
      end

      it "偽を返す" do
        registers.each do |register|
          expect(register).not_to be_read_only
        end
      end
    end

    context "外部レジスタの場合" do
      let(:load_data) do
        [
          [nil, "register_0", "0x00", nil, nil, true]
        ]
      end

      it "偽を返す" do
        expect(registers[0]).not_to be_read_only
      end
    end
  end

  describe "#write_only?" do
    context "書き込み可能かつ読み出し可能なビットフィールドが含まれない場合" do
      let(:load_data) do
        [
          [nil, "registers_0", "0x00", nil, nil, nil, "bit_field_0_0", "[0]", "wo"      , nil, nil],
          [nil, "registers_1", "0x04", nil, nil, nil, "bit_field_1_0", "[1]", "wo"      , nil, nil],
          [nil, nil          , nil   , nil, nil, nil, "bit_field_1_1", "[0]", "wo"      , nil, nil],
          [nil, "registers_2", "0x08", nil, nil, nil, "bit_field_2_0", "[1]", "reserved", nil, nil],
          [nil, nil          , nil   , nil, nil, nil, "bit_field_2_1", "[0]", "wo"      , nil, nil]
        ]
      end

      it "真を返す" do
        registers.each do |register|
          expect(register).to be_write_only
        end
      end
    end

    context "読み出しなビットフィールドが含まれる場合" do
      let(:load_data) do
        [
          [nil, "registers_0", "0x00", nil, nil, nil, "bit_field_0_0", "[1]", "wo", nil, nil],
          [nil, nil          , nil   , nil, nil, nil, "bit_field_0_1", "[0]", "rw", 0  , nil],
          [nil, "registers_1", "0x04", nil, nil, nil, "bit_field_1_0", "[1]", "wo", nil, nil],
          [nil, nil          , nil   , nil, nil, nil, "bit_field_1_1", "[0]", "ro", nil, nil]
        ]
      end

      it "偽を返す" do
        registers.each do |register|
          expect(register).not_to be_write_only
        end
      end
    end

    context "書き込み可能なビットフィールドが含まれない場合" do
      let(:load_data) do
        [
          [nil, "registers_0", "0x00", nil, nil, nil, "bit_field_0_0", "[0]", "ro"      , nil, nil],
          [nil, "registers_1", "0x04", nil, nil, nil, "bit_field_1_0", "[0]", "reserved", nil, nil],
          [nil, "registers_2", "0x08", nil, nil, nil, "bit_field_2_0", "[1]", "reserved", nil, nil],
          [nil, nil          , nil   , nil, nil, nil, "bit_field_2_1", "[0]", "ro"      , nil, nil]
        ]
      end

      it "偽を返す" do
        registers.each do |register|
          expect(register).not_to be_write_only
        end
      end
    end

    context "外部レジスタの場合" do
      let(:load_data) do
        [
          [nil, "register_0", "0x00", nil, nil, true]
        ]
      end

      it "偽を返す" do
        expect(registers[0]).not_to be_write_only
      end
    end
  end

  describe "#reserved" do
    context "含まれるビットフィールドがすべて読み書き不可の場合" do
      let(:load_data) do
        [
          [nil, "registers_0", "0x00", nil, nil, nil, "bit_field_0_0", "[0]", "reserved", nil, nil],
          [nil, "registers_1", "0x04", nil, nil, nil, "bit_field_1_0", "[1]", "reserved", nil, nil],
          [nil, nil          , nil   , nil, nil, nil, "bit_field_1_1", "[0]", "reserved", nil, nil]
        ]
      end

      it "真を返す" do
        registers.each do |register|
          expect(register).to be_reserved
        end
      end
    end

    context "1つ以上の読み書き可能ビットフィールドが含まれる場合" do
      let(:load_data) do
        [
          [nil, "registers_0", "0x00", nil, nil, nil, "bit_field_0_0", "[0]", "rw"      , 0  , nil],
          [nil, "registers_1", "0x00", nil, nil, nil, "bit_field_1_0", "[0]", "ro"      , nil, nil],
          [nil, "registers_2", "0x00", nil, nil, nil, "bit_field_2_0", "[0]", "wo"      , nil, nil],
          [nil, "registers_3", "0x00", nil, nil, nil, "bit_field_3_0", "[1]", "reserved", nil, nil],
          [nil, nil          , nil   , nil, nil, nil, "bit_field_3_1", "[0]", "rw"      , 0  , nil],
          [nil, "registers_4", "0x00", nil, nil, nil, "bit_field_4_0", "[1]", "reserved", nil, nil],
          [nil, nil          , nil   , nil, nil, nil, "bit_field_4_1", "[0]", "ro"      , nil, nil],
          [nil, "registers_5", "0x00", nil, nil, nil, "bit_field_5_0", "[1]", "reserved", nil, nil],
          [nil, nil          , nil   , nil, nil, nil, "bit_field_5_1", "[0]", "wo"      , nil, nil]
        ]
      end

      it "偽を返す" do
        registers.each do |register|
          expect(register).not_to be_reserved
        end
      end
    end

    context "外部レジスタの場合" do
      let(:load_data) do
        [
          [nil, "register_0", "0x00", nil, nil, true]
        ]
      end

      it "偽を返す" do
        expect(registers[0]).not_to be_reserved
      end
    end
  end
end
