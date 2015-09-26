require_relative '../spec_helper'

describe 'type/bit_field' do
  include_context 'register_map common'
  include_context 'configuration common'

  before(:all) do
    RGen.list_item(:bit_field, :type, :foo) do
      register_map {read_write}
    end
    RGen.list_item(:bit_field, :type, :bar) do
      register_map {read_only}
    end
    RGen.list_item(:bit_field, :type, :baz) do
      register_map {write_only}
    end
    RGen.list_item(:bit_field, :type, :qux) do
      register_map {reserved}
    end

    RGen.enable(:register_block , :name)
    RGen.enable(:register       , :name)
    RGen.enable(:bit_field      , :type)
    RGen.enable(:bit_field      , :type, [:foo, :bar, :baz, :qux])
    @factory  = build_register_map_factory
  end

  before(:all) do
    ConfigurationDummyLoader.load_data({})
    @configuration_factory  = build_configuration_factory
  end

  after(:all) do
    clear_enabled_items
    clear_dummy_types
  end

  let(:configuration) do
    @configuration_factory.create(configuration_file)
  end

  def clear_dummy_types
    RGen.generator.builder.categories.each_value do |category|
      category.instance_variable_get(:@item_stores).each_value do |item_store|
        entry = item_store.instance_variable_get(:@list_item_entries)[:type]
        next if entry.nil?
        entry.instance_variable_get(:@items).delete(:foo)
        entry.instance_variable_get(:@items).delete(:bar)
        entry.instance_variable_get(:@items).delete(:baz)
        entry.instance_variable_get(:@items).delete(:qux)
      end
    end
  end

  def type_attributes(cell_value)
    case cell_value.downcase
    when 'foo'
      {type: :foo, readable: true, writable: true}
    when 'bar'
      {type: :bar, readable: true, writable: false}
    when 'baz'
      {type: :baz, readable: false, writable: true}
    when 'qux'
      {type: :qux, readable: false, writable: false}
    end
  end

  context "有効にされたタイプが与えられた場合" do
    let(:types) do
      %w(foo bar baz qux QUX BAZ BAR FOO bAr BaZ Foo quX)
    end

    let(:load_data) do
      [
        [nil, nil         , "block_0"],
        [nil, nil         , nil      ],
        [nil, nil         , nil      ],
        [nil, "register_0", types[0 ]],
        [nil, nil         , types[1 ]],
        [nil, nil         , types[2 ]],
        [nil, nil         , types[3 ]],
        [nil, "register_1", types[4 ]],
        [nil, nil         , types[5 ]],
        [nil, nil         , types[6 ]],
        [nil, nil         , types[7 ]],
        [nil, "register_2", types[8 ]],
        [nil, nil         , types[9 ]],
        [nil, "register_3", types[10]],
        [nil, nil         , types[11]]
      ]
    end

    let(:register_map) do
      @factory.create(configuration, register_map_file)
    end

    before do
      RegisterMapDummyLoader.load_data("block_0" => load_data)
    end

    specify "生成されたビットフィールドは入力されたタイプの属性を持つ" do
      types.each_with_index do |type, i|
        expect(register_map.bit_fields[i]).to match_type(type_attributes(type))
      end
    end
  end
end
