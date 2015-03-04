require_relative '../spec_helper'

describe 'name/register_map' do
  include_context 'register_map common'

  before(:all) do
    RGen.enable(:register_block, :name)
    @factory  = build_register_map_factory
  end

  after(:all) do
    clear_enabled_items
  end

  let(:configuration) do
    RGen::Configuration::Configuration.new
  end

  def create_load_data(*values)
    hash  = values.each_with_object({}).with_index do |(value, h), i|
      h["#{value}_#{i}"]  = [[nil, nil, value]]
    end
    create_map(hash, register_map_file)
  end

  context "適切な入力が与えられたとき" do
    describe "#name" do
      let(:valid_names) do
        ["foo", "FOO", "_foo", "f0o"]
      end

      let(:load_data) do
        create_load_data(*valid_names)
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
        load_data = create_load_data(value)
        RegisterMapDummyLoader.load_data(load_data)

        m         = "invalid value for register block name: #{value.inspect}"
        position  = load_data[0][0, 2].position
        expect{
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error(m, position)
      end
    end
  end

  context "入力名が重複するとき" do
    it "RegisterMapErrorを発生させる" do
      load_data = create_load_data("foo", "foo")
      RegisterMapDummyLoader.load_data(load_data)

      m         = "repeated register block name: foo"
      position  = load_data[1][0, 2].position
      expect{
        @factory.create(configuration, register_map_file)
      }.to raise_register_map_error(m, position)
    end
  end
end
