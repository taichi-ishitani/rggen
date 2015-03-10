require_relative '../spec_helper'

describe 'name/register' do
  include_context 'register_map common'

  before(:all) do
    RGen.enable(:register_block, :name)
    RGen.enable(:register      , :name)
    @factory  = build_register_map_factory
  end

  after(:all) do
    clear_enabled_items
  end

  let(:configuration) do
    RGen::Configuration::Configuration.new
  end

  def create_load_data(values)
    hash  = values.each_with_object({}).with_index do |(names, h), index|
      block_name    = "block_#{index}"
      h[block_name] = [[nil, nil, block_name], [], []]
      names.each do |name|
        h[block_name] << [nil, name]
      end
    end
    create_map(hash, register_map_file)
  end

  context "適切な入力が与えられた場合" do
    describe "#name" do
      let(:valid_names) do
        ["foo", "FOO", "_foo", "f0o"]
      end

      let(:load_data) do
        create_load_data([valid_names])
      end

      let(:register_map) do
        @factory.create(configuration, register_map_file)
      end

      before do
        RegisterMapDummyLoader.load_data(load_data)
      end

      it "入力されたブロック名を返す" do
        valid_names.each_with_index do |name, i|
          expect(register_map.registers[i]).to match_name(name)
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
        load_data = create_load_data([[value]])
        RegisterMapDummyLoader.load_data(load_data)

        m         = "invalid value for register name: #{value.inspect}"
        position  = load_data[0][3, 1].position
        expect{
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error(m, position)
      end
    end
  end

  context "入力名がブロック内で重複するとき" do
    it "RegisterMapErrorを発生させる" do
      load_data = create_load_data([["foo", "foo"]])
      RegisterMapDummyLoader.load_data(load_data)

      m         = "repeated register name: foo"
      position  = load_data[0][4, 1].position
      expect{
        @factory.create(configuration, register_map_file)
      }.to raise_register_map_error(m, position)
    end
  end

  context "入力名がブロック外で重複するとき" do
    specify "RegisterMapErrorは発生しない" do
      load_data = create_load_data([["foo"], ["foo"]])
      RegisterMapDummyLoader.load_data(load_data)
      expect{
        @factory.create(configuration, register_map_file)
      }.not_to raise_register_map_error
    end
  end
end
