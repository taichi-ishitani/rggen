require_relative '../spec_helper'

describe 'name/bit_field' do
  include_context 'register_map common'

  before(:all) do
    RGen.enable(:register_block, :name)
    RGen.enable(:register      , :name)
    RGen.enable(:bit_field     , :name)
    @factory  = build_register_map_factory
  end

  after(:all) do
    clear_enabled_items
  end

  let(:configuration) do
    RGen::Configuration::Configuration.new
  end

  context "適切な入力が与えられた場合" do
    describe "#name" do
      let(:valid_names) do
        ["foo", "FOO", "_foo", "f0o"]
      end

      let(:load_data) do
        {
          "block_0" => [
            [nil, nil         , "block_0"     ],
            [nil, nil         , nil           ],
            [nil, nil         , nil           ],
            [nil, "register_0", valid_names[0]],
            [nil, nil         , valid_names[1]],
            [nil, nil         , valid_names[2]],
            [nil, nil         , valid_names[3]]
          ]
        }
      end

      let(:register_map) do
        @factory.create(configuration, register_map_file)
      end

      before do
        RegisterMapDummyLoader.load_data(load_data)
      end

      it "入力されたビットフィールド名を返す" do
        valid_names.each_with_index do |name, i|
          expect(register_map.bit_fields[i]).to match_name(name)
        end
      end
    end
  end

  context "入力が変数名に適さないとき" do
    let(:invalid_values) do
      ["1foo", "foo!", " ", "foo\nbar"]
    end

    it "RegisterMapErrorを発生させる" do
      invalid_values.each do |value|
        load_data = {
          "block_0" => [
            [nil, nil         , "block_0"],
            [nil, nil         , nil      ],
            [nil, nil         , nil      ],
            [nil, "register_0", value    ]
          ]
        }
        RegisterMapDummyLoader.load_data(load_data)

        message = "invalid value for bit field name: #{value.inspect}"
        expect{
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error(message, position("block_0", 3, 2))
      end
    end
  end

  context "入力名が同一レジスタ内で重複するとき" do
    let(:load_data) do
      {
        "block_0" => [
          [nil, nil         , "block_0"],
          [nil, nil         , nil      ],
          [nil, nil         , nil      ],
          [nil, "register_0", "foo"    ],
          [nil, nil         , "foo"    ]
        ]
      }
    end

    before do
      RegisterMapDummyLoader.load_data(load_data)
    end

    it "RegisterMapErrorを発生させる" do
      message = "repeated bit field name: foo"
      expect{
        @factory.create(configuration, register_map_file)
      }.to raise_register_map_error(message, position("block_0", 4, 2))
    end
  end

  context "入力名が同一ブロック内で重複するとき" do
    let(:load_data) do
      {
        "block_0" => [
          [nil, nil         , "block_0"],
          [nil, nil         , nil      ],
          [nil, nil         , nil      ],
          [nil, "register_0", "foo"    ],
          [nil, "register_1", "foo"    ]
        ]
      }
    end

    before do
      RegisterMapDummyLoader.load_data(load_data)
    end

    it "RegisterMapErrorを発生させる" do
      message = "repeated bit field name: foo"
      expect{
        @factory.create(configuration, register_map_file)
      }.to raise_register_map_error(message, position("block_0", 4, 2))
    end
  end

  context "入力名が同一ブロック内で重複するとき" do
    let(:load_data) do
      {
        "block_0" => [
          [nil, nil         , "block_0"],
          [nil, nil         , nil      ],
          [nil, nil         , nil      ],
          [nil, "register_0", "foo"    ]
        ],
        "block_1" => [
          [nil, nil         , "block_1"],
          [nil, nil         , nil      ],
          [nil, nil         , nil      ],
          [nil, "register_0", "foo"    ]
        ]
      }
    end

    before do
      RegisterMapDummyLoader.load_data(load_data)
    end

    it "RegisterMapErrorを発生させない" do
      expect{
        @factory.create(configuration, register_map_file)
      }.not_to raise_register_map_error
    end
  end
end