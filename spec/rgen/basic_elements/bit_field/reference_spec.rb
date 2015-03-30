require_relative '../spec_helper'

describe 'reference/bit_field' do
  include_context 'register_map common'

  before(:all) do
    RGen.enable(:register_block, :name     )
    RGen.enable(:register      , :name     )
    RGen.enable(:bit_field     , :name     )
    RGen.enable(:bit_field     , :reference)
    @factory  = build_register_map_factory
  end

  after(:all) do
    clear_enabled_items
  end

  let(:configuration) do
    RGen::Configuration::Configuration.new
  end

  context "入力が空のとき" do
    let(:load_data) do
      [
        [nil, nil         , "block_0"         ],
        [nil, nil         , nil               ],
        [nil, nil         , nil               ],
        [nil, "register_0", "bit_field_0", nil],
        [nil, nil         , "bit_field_1", "" ]
      ]
    end

    let(:register_map) do
      @factory.create(configuration, register_map_file)
    end

    before do
      RegisterMapDummyLoader.load_data("block_0" => load_data)
    end

    describe "#has_reference?" do
      it "偽を返す" do
        register_map.bit_fields.each do |bit_field|
          expect(bit_field).to_not have_reference
        end
      end
    end

    describe "#has_no_reference?" do
      it "真を返す" do
        register_map.bit_fields.each do |bit_field|
          expect(bit_field).to have_no_reference
        end
      end
    end

    describe "#has_external_reference?" do
      it "偽を返す" do
        register_map.bit_fields.each do |bit_field|
          expect(bit_field).to_not have_external_reference
        end
      end
    end

    describe "#has_no_external_reference?" do
      it "真を返す" do
        register_map.bit_fields.each do |bit_field|
          expect(bit_field).to have_no_external_reference
        end
      end
    end

    describe "#reference" do
      it "nilを返す" do
        register_map.bit_fields.each do |bit_field|
          expect(bit_field.reference).to be_nil
        end
      end
    end
  end

  context "入力が'external'のとき" do
    let(:load_data) do
      [
        [nil, nil         , "block_0"                ],
        [nil, nil         , nil                      ],
        [nil, nil         , nil                      ],
        [nil, "register_0", "bit_field_0", "external"],
        [nil, nil         , "bit_field_1", "EXTERNAL"],
        [nil, nil         , "bit_field_2", "eXtErNaL"]
      ]
    end

    let(:register_map) do
      @factory.create(configuration, register_map_file)
    end

    before do
      RegisterMapDummyLoader.load_data("block_0" => load_data)
    end

    describe "#has_reference?" do
      it "真を返す" do
        register_map.bit_fields.each do |bit_field|
          expect(bit_field).to have_reference
        end
      end
    end

    describe "#has_no_reference?" do
      it "偽を返す" do
        register_map.bit_fields.each do |bit_field|
          expect(bit_field).not_to have_no_reference
        end
      end
    end

    describe "#has_external_reference?" do
      it "真を返す" do
        register_map.bit_fields.each do |bit_field|
          expect(bit_field).to have_external_reference
        end
      end
    end

    describe "#has_no_external_reference?" do
      it "偽を返す" do
        register_map.bit_fields.each do |bit_field|
          expect(bit_field).not_to have_no_external_reference
        end
      end
    end

    describe "#reference" do
      it "nilを返す" do
        register_map.bit_fields.each do |bit_field|
          expect(bit_field.reference).to be_nil
        end
      end
    end
  end

  context "入力がビットフィールド名のとき" do
    let(:load_data) do
      [
        [nil, nil         , "block_0"                   ],
        [nil, nil         , nil                         ],
        [nil, nil         , nil                         ],
        [nil, "register_0", "bit_field_0", "bit_field_1"],
        [nil, nil         , "bit_field_1", "bit_field_0"],
        [nil, "register_1", "bit_field_2", "bit_field_3"],
        [nil, "register_2", "bit_field_3", "bit_field_2"]
      ]
    end

    let(:register_map) do
      @factory.create(configuration, register_map_file)
    end

    before do
      RegisterMapDummyLoader.load_data("block_0" => load_data)
    end

    describe "#has_reference?" do
      it "真を返す" do
        register_map.bit_fields.each do |bit_field|
          expect(bit_field).to have_reference
        end
      end
    end

    describe "#has_no_reference?" do
      it "偽を返す" do
        register_map.bit_fields.each do |bit_field|
          expect(bit_field).not_to have_no_reference
        end
      end
    end

    describe "#has_external_reference?" do
      it "偽を返す" do
        register_map.bit_fields.each do |bit_field|
          expect(bit_field).not_to have_external_reference
        end
      end
    end

    describe "#has_no_external_reference?" do
      it "真を返す" do
        register_map.bit_fields.each do |bit_field|
          expect(bit_field).to have_no_external_reference
        end
      end
    end

    describe "#reference" do
      it "指定されたビットフィールドオブジェクトを返す" do
        expect(register_map.bit_fields[0].reference).to eql register_map.bit_fields[1]
        expect(register_map.bit_fields[1].reference).to eql register_map.bit_fields[0]
        expect(register_map.bit_fields[2].reference).to eql register_map.bit_fields[3]
        expect(register_map.bit_fields[3].reference).to eql register_map.bit_fields[2]
      end
    end
  end

  context "入力が自分のビットフィールド名のとき" do
    let(:load_data) do
      [
        [nil, nil         , "block_0"                   ],
        [nil, nil         , nil                         ],
        [nil, nil         , nil                         ],
        [nil, "register_0", "bit_field_0", "bit_field_0"]
      ]
    end

    before do
      RegisterMapDummyLoader.load_data("block_0" => load_data)
    end

    it "RegisterMapErrorを発生させる" do
      message = "self reference: bit_field_0"
      expect{
        @factory.create(configuration, register_map_file)
      }.to raise_register_map_error(message, position("block_0", 3, 3))
    end
  end

  context "入力されたビットフィールド名が存在しないとき" do
    let(:load_data) do
      [
        [nil, nil         , "block_0"                   ],
        [nil, nil         , nil                         ],
        [nil, nil         , nil                         ],
        [nil, "register_0", "bit_field_0", "bit_field_5"],
        [nil, nil         , "bit_field_1", nil          ]
      ]
    end

    before do
      RegisterMapDummyLoader.load_data("block_0" => load_data)
    end

    it "RegisterMapErrorを発生させる" do
      message = "no such reference bit field: bit_field_5"
      expect{
        @factory.create(configuration, register_map_file)
      }.to raise_register_map_error(message, position("block_0", 3, 3))
    end
  end
end
