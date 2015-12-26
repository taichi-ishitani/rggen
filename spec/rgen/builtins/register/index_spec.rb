require_relative '../spec_helper'

describe 'register/index' do
  include_context 'bit field type common'
  include_context 'configuration common'
  include_context 'rtl common'

  before(:all) do
    enable :register_block, :name
    enable :register      , :name
    enable :bit_field     , :name
    enable :register      , :index

    configuration = create_configuration
    register_map  = create_register_map(
      configuration,
      "block_0" => [
        [nil, nil         , "block_0"    ],
        [                                ],
        [                                ],
        [nil, "register_0", "bit_field_0"],
        [nil, "register_1", "bit_field_1"],
        [nil, "register_2", "bit_field_2"]
      ],
      "block_1" => [
        [nil, nil         , "block_1"    ],
        [                                ],
        [                                ],
        [nil, "register_0", "bit_field_0"],
        [nil, "register_1", "bit_field_1"]
      ]
    )

    @rtl  = build_rtl_factory.create(configuration, register_map)
  end

  after(:all) do
    clear_enabled_items
  end

  let(:rtl) do
    @rtl
  end

  describe "#index" do
    it "自身が属するレジスタブロック内でのインデックスを返す" do
      expect(rtl.registers.map(&:index)).to match [
        0, 1, 2, 0, 1
      ]
    end
  end
end
