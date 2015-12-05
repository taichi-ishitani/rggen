require_relative '../spec_helper'

describe 'bit_field/reference' do
  include_context 'register_map common'

  before(:all) do
    RGen.enable(:register_block, :name     )
    RGen.enable(:register      , :name     )
    RGen.enable(:bit_field     , :name     )
    RGen.enable(:bit_field     , :reference)
    RGen.enable(:bit_field     , :type     )
    RGen.enable(:bit_field     , :type     , [:rw, :reserved])
    @factory  = build_register_map_factory
  end

  after(:all) do
    clear_enabled_items
  end

  let(:configuration) do
    RGen::InputBase::Component.new(nil)
  end

  context "入力が空のとき" do
    let(:load_data) do
      [
        [nil, nil         , "block_0"               ],
        [nil, nil         , nil                     ],
        [nil, nil         , nil                     ],
        [nil, "register_0", "bit_field_0", nil, "rw"],
        [nil, nil         , "bit_field_1", "" , "rw"]
      ]
    end

    let(:register_map) do
      @factory.create(configuration, register_map_file)
    end

    before do
      RegisterMapDummyLoader.load_data("block_0" => load_data)
    end

    describe "#reference" do
      it "nilを返す" do
        register_map.bit_fields.each do |bit_field|
          expect(bit_field.reference).to be_nil
        end
      end
    end

    describe "#has_reference?" do
      it "偽を返す" do
        register_map.bit_fields.each do |bit_field|
          expect(bit_field).to_not have_reference
        end
      end
    end
  end

  context "参照ビットフィールドの指定があるとき" do
    let(:load_data) do
      [
        [nil, nil         , "block_0"                         ],
        [nil, nil         , nil                               ],
        [nil, nil         , nil                               ],
        [nil, "register_0", "bit_field_0", "bit_field_1", "rw"],
        [nil, nil         , "bit_field_1", "bit_field_0", "rw"],
        [nil, "register_1", "bit_field_2", "bit_field_3", "rw"],
        [nil, "register_2", "bit_field_3", "bit_field_2", "rw"]
      ]
    end

    let(:register_map) do
      @factory.create(configuration, register_map_file)
    end

    before do
      RegisterMapDummyLoader.load_data("block_0" => load_data)
    end

    describe "#reference" do
      it "指定されたビットフィールドオブジェクトを返す" do
        expect(register_map.bit_fields[0].reference).to eql register_map.bit_fields[1]
        expect(register_map.bit_fields[1].reference).to eql register_map.bit_fields[0]
        expect(register_map.bit_fields[2].reference).to eql register_map.bit_fields[3]
        expect(register_map.bit_fields[3].reference).to eql register_map.bit_fields[2]
      end
    end

    describe "#has_reference?" do
      it "真を返す" do
        register_map.bit_fields.each do |bit_field|
          expect(bit_field).to have_reference
        end
      end
    end
  end

  context "入力が自分のビットフィールド名のとき" do
    let(:load_data) do
      [
        [nil, nil         , "block_0"                         ],
        [nil, nil         , nil                               ],
        [nil, nil         , nil                               ],
        [nil, "register_0", "bit_field_0", "bit_field_0", "rw"]
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
        [nil, nil         , "block_0"                         ],
        [nil, nil         , nil                               ],
        [nil, nil         , nil                               ],
        [nil, "register_0", "bit_field_0", "bit_field_5", "rw"],
        [nil, nil         , "bit_field_1", nil          , "rw"]
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

  context "入力されたビットフィールドの属性がreservedのとき" do
    let(:load_data) do
      [
        [nil, nil         , "block_0"                               ],
        [nil, nil         , nil                                     ],
        [nil, nil         , nil                                     ],
        [nil, "register_0", "bit_field_0", "bit_field_1", "rw"      ],
        [nil, nil         , "bit_field_1", nil          , "reserved"]
      ]
    end

    before do
      RegisterMapDummyLoader.load_data("block_0" => load_data)
    end

    it "RegisterMapErrorを発生させる" do
      message = "reserved bit field is refered: bit_field_1"
      expect{
        @factory.create(configuration, register_map_file)
      }.to raise_register_map_error(message, position("block_0", 3, 3))
    end
  end

  specify "#reference呼び出し時に#validateが呼び出される" do
    RegisterMapDummyLoader.load_data("block_0" => [
      [nil, nil         , "block_0"              ],
      [nil, nil         , nil                    ],
      [nil, nil         , nil                    ],
      [nil, "register_0", "bit_field_0", "", "rw"]
    ])
    register_map  = @factory.create(configuration, register_map_file)

    expect(register_map.bit_fields[0].items[1]).to receive(:validate).with(no_args)
    register_map.bit_fields[0].reference
  end
end
