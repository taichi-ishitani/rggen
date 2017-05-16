require_relative '../spec_helper'

describe 'register/array' do
  include_context 'register common'
  include_context 'configuration common'
  include_context 'rtl common'

  before(:all) do
    enable :register_block, [:name, :byte_size]
    enable :register      , [:name, :offset_address, :array, :type]
    enable :register      , :type, :indirect
    enable :bit_field     , [:name, :bit_assignment, :type, :initial_value]
    enable :bit_field     , :type, [:rw]
    enable :register_block, [:clock_reset, :host_if]
    enable :register_block, :host_if, :apb
  end

  before(:all) do
    enable :global, [:data_width, :address_width]
    @configuration  = create_configuration(data_width: 32, address_width: 16)
  end

  after(:all) do
    clear_enabled_items
  end

  let(:configuration) do
    @configuration
  end

  describe 'register_map' do
    before(:all) do
      @factory  = build_register_map_factory
    end

    context "入力がnilや空文字の場合" do
      let(:load_data) do
        [
          [nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[31:0]", "rw", 0],
          [nil, "register_1", "0x04", "" , nil, "bit_field_1_0", "[31:0]", "rw", 0]
        ]
      end

      describe "#array?" do
        it "偽を返す" do
          expect(registers.map(&:array?)).to all(be_falsey)
        end
      end

      describe "#dimensions" do
        it "nilを返す" do
          expect(registers.map(&:dimensions)).to all(be_nil)
        end
      end

      describe "#count" do
        it "1を返す" do
          expect(registers.map(&:count)).to all(eq(1))
        end
      end
    end

    context "適切な入力が与えられた場合" do
      let(:load_data) do
        [
          [nil, "register_0", "0x00"     , "[ 1]"     , nil                                  , "bit_field_0_0", "[31:0]" , "rw", 0],
          [nil, "register_1", "0x04-0x0B", "[2 ]"     , nil                                  , "bit_field_1_0", "[31:0]" , "rw", 0],
          [nil, "register_2", "0x20-0x47", "[10]"     , nil                                  , "bit_field_2_0", "[31:0]" , "rw", 0],
          [nil, "register_3", "0x50"     , "[2, 3, 4]", "indirect: index_0, index_1, index_2", "bit_field_3_0", "[31:0]" , "rw", 0],
          [nil, "regsiter_4", "0x54"     , nil        , nil                                  , "index_0"      , "[17:16]", "rw", 0],
          [nil, nil         , nil        , nil        , nil                                  , "index_1"      , "[ 9: 8]", "rw", 0],
          [nil, nil         , nil        , nil        , nil                                  , "index_2"      , "[ 1: 0]", "rw", 0]
        ]
      end

      describe "#array?" do
        it "真を返す" do
          expect(registers.first(4).map(&:array?)).to all(be_truthy)
        end
      end

      describe "#dimensions" do
        it "次元を配列で返す" do
          expect(registers.first(4).map(&:dimensions)).to match([
            [1], [2], [10], [2, 3, 4]
          ])
        end
      end

      describe "#count" do
        it "含まれるレジスタの総数を返す" do
          expect(registers.first(4).map(&:count)).to match([
            1, 2, 10, 24
          ])
        end
      end
    end

    context "入力が配列設定に適さないとき" do
      let(:invalid_values) do
        ["[-1]", "[01]", "[1.0]", "[1", "1]", "1", "[\n1]", "foo"]
      end

      it "RegisterMapErrorを発生させる" do
        invalid_values.each do |invalid_value|
          set_load_data([
            [nil, "register_0", "0x00", invalid_value, nil, "bit_field_0_0", "[31:0]", "rw", 0]
          ])

          message = "invalid value for array dimension: #{invalid_value.inspect}"
          expect {
            @factory.create(configuration, register_map_file)
          }.to raise_register_map_error(message, position("block_0", 4, 3))
        end
      end
    end

    context "配列の大きさに0が設定されたとき" do
      let(:invalid_value) do
        "[0]"
      end

      it do
        set_load_data([
          [nil, "register_0", "0x00", invalid_value, nil, "bit_field_0_0", "[31:0]", "rw", 0]
        ])

        message = "0 is not allowed for array dimension: #{invalid_value.inspect}"
        expect {
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error(message, position("block_0", 4, 3))
      end
    end
  end
end
