require_relative '../spec_helper'

describe "register_block/c_header_file" do
  include_context 'configuration common'
  include_context 'register_map common'
  include_context 'c header common'

  before(:all) do
    enable :global, [:data_width, :address_width]
    @configuration  = create_configuration
  end

  before(:all) do
    enable :register_block, [:name, :byte_size]
    enable :register, [:name, :offset_address, :array, :type]
    enable :register, :type, [:external, :indirect]
    enable :bit_field, [:name, :bit_assignment, :type, :initial_value, :reference]
    enable :bit_field, :type, [:rw, :ro, :wo, :reserved]
    @register_map = create_register_map(
      @configuration,
      "block_0" => [
        [nil, nil, "block_0"                                                                                                           ],
        [nil, nil, 256                                                                                                                 ],
        [                                                                                                                              ],
        [                                                                                                                              ],
        [nil, "register_0", "0x00"       , nil     , nil                                     , "bit_field_0_0", "[31:0]", :rw, 0  , nil]
      ],
      "block_1" => [
        [nil, nil, "block_1"                                                                                                           ],
        [nil, nil, 256                                                                                                                 ],
        [                                                                                                                              ],
        [                                                                                                                              ],
        [nil, "register_0", "0x00"       , nil     , nil                                     , "bit_field_0_0", "[31:0]", :rw, 0  , nil],
        [nil, "register_1", "0x04"       , nil     , nil                                     , "bit_field_1_0", "[31:0]", :ro, 0  , nil],
        [nil, "register_2", "0x08"       , nil     , nil                                     , "bit_field_2_0", "[31:0]", :wo, 0  , nil],
        [nil, "register_3", "0x0C"       , "[2, 2]", "indirect: bit_field_0_0, bit_field_1_0", "bit_field_3_0", "[31:0]", :rw, 0  , nil],
        [nil, "register_4", "0x10"       , "[1]"   , nil                                     , "bit_field_4_0", "[31:0]", :wo, 0  , nil],
        [nil, "register_5", "0x14 - 0x1F", "[3]"   , nil                                     , "bit_field_5_0", "[31:0]", :wo, 0  , nil],
        [nil, "register_6", "0x20 - 0x2F", nil     , "external"                              , nil            , nil     ,nil , nil, nil]
      ]
    )
  end

  before(:all) do
    enable :register_block, [:address_struct, :c_header_file]
    @c_header = build_c_header_factory.create(@configuration, @register_map).register_blocks
  end

  after(:all) do
    clear_enabled_items
  end

  let(:c_header) do
    @c_header
  end

  describe "#write_file" do
    let(:expected_code_0) do
      <<'CODE'
#ifndef BLOCK_0_H
#define BLOCK_0_H
#include "rggen.h"
typedef struct {
  rggen_uint32 register_0;
} s_block_0_address_struct;
#endif
CODE
    end

    let(:expected_code_1) do
      <<'CODE'
#ifndef BLOCK_1_H
#define BLOCK_1_H
#include "rggen.h"
typedef struct {
  rggen_uint32 register_0;
  rggen_uint32 register_1;
  rggen_uint32 register_2;
  rggen_uint32 register_3;
  rggen_uint32 register_4[1];
  rggen_uint32 register_5[3];
  RGGEN_EXTERNAL_REGISTERS(16, REGISTER_6) register_6;
} s_block_1_address_struct;
#endif
CODE
    end

    it "レジスタモジュール用のCヘッダーファイルを書き出す" do
      expect {
        c_header[0].write_file('.')
      }.to write_binary_file("./block_0.h", expected_code_0)
      expect {
        c_header[1].write_file('.')
      }.to write_binary_file("./block_1.h", expected_code_1)
    end
  end
end
