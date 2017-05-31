require_relative '../spec_helper'

describe 'bit_field/field_model' do
  include_context 'bit field type common'
  include_context 'configuration common'
  include_context 'ral common'

  before(:all) do
    enable :global, :data_width
    enable :register_block, :name
    enable :register, :name
    enable :bit_field, [:name, :bit_assignment, :type, :initial_value, :reference]
    enable :bit_field, :type, [:rw, :ro, :w0c, :w1c, :w0s, :w1s, :rwl, :rwe, :reserved]
    enable :bit_field, :field_model

    configuration = create_configuration
    register_map  = create_register_map(
      configuration,
      "block_0" => [
        [nil, nil         ,"block_0"                                                        ],
        [                                                                                   ],
        [                                                                                   ],
        [nil, "register_0", "bit_field_0_0", "[31:0]", "rw"      , "0x0123", nil            ],
        [nil, "register_1", "bit_field_1_0", "[9:8]" , "ro"      , nil     , nil            ],
        [nil, nil         , "bit_field_1_1", "[4]"   , "ro"      , 1       , nil            ],
        [nil, nil         , "bit_field_1_2", "[0]"   , "reserved", nil     , nil            ],
        [nil, "register_2", "bit_field_2_0", "[8]"   , "w0c"     , 0       , nil            ],
        [nil, nil         , "bit_field_2_1", "[0]"   , "w1c"     , 0       , nil            ],
        [nil, "register_3", "bit_field_3_0", "[8]"   , "w0s"     , 0       , nil            ],
        [nil, nil         , "bit_field_3_1", "[0]"   , "w1s"     , 0       , nil            ],
        [nil, "register_4", "bit_field_4_0", "[1]"   , "rwl"     , 0       , "bit_field_5_0"],
        [nil, nil         , "bit_field_4_1", "[0]"   , "rwe"     , 0       , "bit_field_5_1"],
        [nil, "register_5", "bit_field_5_0", "[1]"   , "rw"      , 0       , nil            ],
        [nil, nil         , "bit_field_5_1", "[0]"   , "rw"      , 0       , nil            ],
      ]
    )
    @ral  = build_ral_factory.create(configuration, register_map)
  end

  after(:all) do
    clear_enabled_items
  end

  let(:bit_fields) do
    @ral.bit_fields
  end

  let(:model_field_4_0) do
    'rggen_ral_field_rwl#("register_5", "bit_field_5_0")'
  end

  let(:model_field_4_1) do
    'rggen_ral_field_rwe#("register_5", "bit_field_5_1")'
  end

  describe "#build" do
    it "所有者コンポーネントに自身の宣言を追加する" do
      expect(bit_fields[0]).to have_variable(:reg_model, :field_model, data_type: :rggen_ral_field, name: 'bit_field_0_0', random: true)
      expect(bit_fields[1]).to have_variable(:reg_model, :field_model, data_type: :rggen_ral_field, name: 'bit_field_1_0', random: true)
      expect(bit_fields[2]).to have_variable(:reg_model, :field_model, data_type: :rggen_ral_field, name: 'bit_field_1_1', random: true)
      expect(bit_fields[3]).to have_variable(:reg_model, :field_model, data_type: :rggen_ral_field, name: 'bit_field_1_2', random: true)
      expect(bit_fields[4]).to have_variable(:reg_model, :field_model, data_type: :rggen_ral_field, name: 'bit_field_2_0', random: true)
      expect(bit_fields[5]).to have_variable(:reg_model, :field_model, data_type: :rggen_ral_field, name: 'bit_field_2_1', random: true)
      expect(bit_fields[6]).to have_variable(:reg_model, :field_model, data_type: :rggen_ral_field, name: 'bit_field_3_0', random: true)
      expect(bit_fields[7]).to have_variable(:reg_model, :field_model, data_type: :rggen_ral_field, name: 'bit_field_3_1', random: true)
      expect(bit_fields[8]).to have_variable(:reg_model, :field_model, data_type: model_field_4_0 , name: 'bit_field_4_0', random: true)
      expect(bit_fields[9]).to have_variable(:reg_model, :field_model, data_type: model_field_4_1 , name: 'bit_field_4_1', random: true)
    end
  end

  describe "#model_creation" do
    before do
      bit_fields.each do |bit_field|
        bit_field.model_creation(code)
      end
    end

    let(:code) do
      RgGen::CodeUtility::CodeBlock.new
    end

    let(:expected_code) do
      [
        "`rggen_ral_create_field_model(bit_field_0_0, \"bit_field_0_0\", 32, 0, \"RW\", 0, 32'h00000123, 1, \"g_bit_field_0_0.u_bit_field.value\")\n",
        "`rggen_ral_create_field_model(bit_field_1_0, \"bit_field_1_0\", 2, 8, \"RO\", 0, 2'h0, 0, \"g_bit_field_1_0.u_bit_field.i_value\")\n",
        "`rggen_ral_create_field_model(bit_field_1_1, \"bit_field_1_1\", 1, 4, \"RO\", 0, 1'h1, 1, \"g_bit_field_1_1.u_bit_field.i_value\")\n",
        "`rggen_ral_create_field_model(bit_field_1_2, \"bit_field_1_2\", 1, 0, \"RO\", 0, 1'h0, 0, \"\")\n",
        "`rggen_ral_create_field_model(bit_field_2_0, \"bit_field_2_0\", 1, 8, \"W0C\", 0, 1'h0, 1, \"g_bit_field_2_0.u_bit_field.value\")\n",
        "`rggen_ral_create_field_model(bit_field_2_1, \"bit_field_2_1\", 1, 0, \"W1C\", 0, 1'h0, 1, \"g_bit_field_2_1.u_bit_field.value\")\n",
        "`rggen_ral_create_field_model(bit_field_3_0, \"bit_field_3_0\", 1, 8, \"W0S\", 0, 1'h0, 1, \"g_bit_field_3_0.u_bit_field.value\")\n",
        "`rggen_ral_create_field_model(bit_field_3_1, \"bit_field_3_1\", 1, 0, \"W1S\", 0, 1'h0, 1, \"g_bit_field_3_1.u_bit_field.value\")\n",
        "`rggen_ral_create_field_model(bit_field_4_0, \"bit_field_4_0\", 1, 1, \"RWL\", 0, 1'h0, 1, \"g_bit_field_4_0.u_bit_field.value\")\n",
        "`rggen_ral_create_field_model(bit_field_4_1, \"bit_field_4_1\", 1, 0, \"RWE\", 0, 1'h0, 1, \"g_bit_field_4_1.u_bit_field.value\")\n",
        "`rggen_ral_create_field_model(bit_field_5_0, \"bit_field_5_0\", 1, 1, \"RW\", 0, 1'h0, 1, \"g_bit_field_5_0.u_bit_field.value\")\n",
        "`rggen_ral_create_field_model(bit_field_5_1, \"bit_field_5_1\", 1, 0, \"RW\", 0, 1'h0, 1, \"g_bit_field_5_1.u_bit_field.value\")\n"
      ].join
    end

    it "ビットフィールドモデルを生成するコードを生成する" do
      expect(code.to_s).to eq expected_code
    end
  end
end
