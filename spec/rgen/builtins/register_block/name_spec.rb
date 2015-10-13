require_relative '../spec_helper'

describe 'register_block/name' do
  include_context 'register_map common'

  before(:all) do
    RGen.enable(:register_block, :name)
    @factory  = build_register_map_factory
  end

  after(:all) do
    clear_enabled_items
  end

  let(:configuration) do
    RGen::InputBase::Component.new
  end

  context "適切な入力が与えられたとき" do
    describe "#name" do
      let(:valid_names) do
        ["foo", "FOO", "_foo", "f0o"]
      end

      let(:load_data) do
        {
          "block_0" => [
            [nil, nil, valid_names[0]]
          ],
          "block_1"  => [
            [nil, nil, valid_names[1]]
          ],
          "block_2"  => [
            [nil, nil, valid_names[2]]
          ],
          "block_3"  => [
            [nil, nil, valid_names[3]]
          ]
        }
      end

      let(:register_map) do
        @factory.create(configuration, register_map_file)
      end

      before do
        RegisterMapDummyLoader.load_data(load_data)
      end

      it "入力されたブロック名を返す" do
        valid_names.each_with_index do |name, i|
          expect(register_map.register_blocks[i]).to match_name(name)
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
            [nil, nil, value]
          ]
        }
        RegisterMapDummyLoader.load_data(load_data)

        message = "invalid value for register block name: #{value.inspect}"
        expect{
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error(message, position("block_0", 0, 2))
      end
    end
  end

  context "入力名が重複するとき" do
    let(:load_data) do
      {
        "block_0" => [
          [nil, nil, "foo"]
        ],
        "block_1" => [
          [nil, nil, "foo"]
        ]
      }
    end

    before do
      RegisterMapDummyLoader.load_data(load_data)
    end

    it "RegisterMapErrorを発生させる" do
      message = "repeated register block name: foo"
      expect{
        @factory.create(configuration, register_map_file)
      }.to raise_register_map_error(message, position("block_1", 0, 2))
    end
  end
end
