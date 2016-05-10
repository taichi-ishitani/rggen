require_relative '../spec_helper'

describe 'register/external' do
  include_context 'bit field type common'
  include_context 'configuration common'

  before(:all) do
    enable :register_block, [:name, :byte_size]
    enable :register      , [:name, :offset_address, :array, :shadow, :external, :accessibility]
    enable :bit_field     , [:name, :bit_assignment, :type, :initial_value]
    enable :bit_field     , :type, [:rw]
    @factory  = build_register_map_factory
  end

  before(:all) do
    enable :global, [:data_width, :address_width]
    @configuration  = create_configuration
  end

  after(:all) do
    clear_enabled_items
  end

  let(:configuration) do
    @configuration
  end

  let(:factory) do
    @factory
  end

  let(:registers) do
    block_data  = [
      [nil, nil, "block_0"],
      [nil, nil, 256      ],
      [                   ],
      [                   ]
    ]
    block_data.concat(load_data)
    RegisterMapDummyLoader.load_data("block_0" => block_data)
    @factory.create(configuration, register_map_file).registers
  end

  context "入力がnilや空文字の場合" do
    let(:load_data) do
      [
        [nil, "register_0", "0x00", nil, nil, nil, "bit_field_0_0", "[0]", "rw", 0],
        [nil, "register_1", "0x04", nil, nil, "" , "bit_field_1_0", "[0]", "rw", 0]
      ]
    end

    specify "当該レジスタは内部レジスタである" do
      expect(registers[0]).not_to be_external
      expect(registers[1]).not_to be_external
    end

    specify "当該レジスタはビットフィールドを持つ" do
      expect(registers[0].bit_fields).not_to be_empty
      expect(registers[1].bit_fields).not_to be_empty
    end
  end

  context "入力がfalseの場合" do
    let(:load_data) do
      [
        [nil, "register_0", "0x00", nil, nil, false   , "bit_field_0_0", "[0]", "rw", 0],
        [nil, "register_1", "0x04", nil, nil, "false" , "bit_field_1_0", "[0]", "rw", 0],
        [nil, "register_2", "0x08", nil, nil, "FALSE" , "bit_field_2_0", "[0]", "rw", 0],
        [nil, "register_3", "0x0C", nil, nil, "fAlSe" , "bit_field_3_0", "[0]", "rw", 0]
      ]
    end

    specify "当該レジスタは内部レジスタである" do
      expect(registers[0]).not_to be_external
      expect(registers[1]).not_to be_external
      expect(registers[2]).not_to be_external
      expect(registers[3]).not_to be_external
    end

    specify "当該レジスタはビットフィールドを持つ" do
      expect(registers[0].bit_fields).not_to be_empty
      expect(registers[1].bit_fields).not_to be_empty
      expect(registers[2].bit_fields).not_to be_empty
      expect(registers[3].bit_fields).not_to be_empty
    end
  end

  context "入力がtrueの場合" do
    let(:load_data) do
      [
        [nil, "register_0", "0x00", nil, nil, true  , "bit_field_0_0", "[0]", "rw", 0],
        [nil, "register_1", "0x04", nil, nil, "true", "bit_field_1_0", "[0]", "rw", 0],
        [nil, "register_2", "0x08", nil, nil, "TRUE", "bit_field_2_0", "[0]", "rw", 0],
        [nil, "register_3", "0x0C", nil, nil, "TrUe", "bit_field_3_0", "[0]", "rw", 0]
      ]
    end

    specify "当該レジスタは外部レジスタである" do
      expect(registers[0]).to be_external
      expect(registers[1]).to be_external
      expect(registers[2]).to be_external
      expect(registers[3]).to be_external
    end

    specify "当該レジスタはビットフィールドを持たない" do
      expect(registers[0].bit_fields).to be_empty
      expect(registers[1].bit_fields).to be_empty
      expect(registers[2].bit_fields).to be_empty
      expect(registers[3].bit_fields).to be_empty
    end
  end
end
