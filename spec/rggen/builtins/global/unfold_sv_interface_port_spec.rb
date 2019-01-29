require_relative '../spec_helper'

describe 'global/unfold_sv_interface_port' do
  include_context 'configuration common'

  before(:all) do
    RgGen.enable(:global, :unfold_sv_interface_port)
    @factory  = build_configuration_factory
  end

  after(:all) do
    clear_enabled_items
  end

  describe "#unfold_sv_interface_port?" do
    context "ロード結果のHashに:unfold_sv_interface_portが含まれないとき" do
      it "falseを返す" do
        ConfigurationDummyLoader.load_data({})
        c = @factory.create(configuration_file)
        expect(c.unfold_sv_interface_port?).to be false
      end
    end

    context "ロード結果のHashに:unfold_sv_interface_portが含まれていて、nilの場合" do
      it "falseを返す" do
        ConfigurationDummyLoader.load_data({ unfold_sv_interface_port: nil })
        c = @factory.create(configuration_file)
        expect(c.unfold_sv_interface_port?).to be false
      end
    end

    context "ロード結果のHashに:unfold_sv_interface_portが含まれていて、ブール値でtrueの場合" do
      it "trueを返す" do
        ConfigurationDummyLoader.load_data({ unfold_sv_interface_port: true })
        c = @factory.create(configuration_file)
        expect(c.unfold_sv_interface_port?).to be true
      end
    end

    context "ロード結果のHashに:unfold_sv_interface_portが含まれていて、ブール値でfalseの場合" do
      it "trueを返す" do
        ConfigurationDummyLoader.load_data({ unfold_sv_interface_port: false })
        c = @factory.create(configuration_file)
        expect(c.unfold_sv_interface_port?).to be false
      end
    end

    context "ロード結果のHashに:unfold_sv_interface_portが含まれていて、値がtrue/on/yesのいずれかの場合" do
      let(:load_data) do
        ['true', 'on', 'yes']
      end

      it "trueを返す" do
        load_data.each do |data|
          ConfigurationDummyLoader.load_data({ unfold_sv_interface_port: random_updown_case(data) })
          c = @factory.create(configuration_file)
          expect(c.unfold_sv_interface_port?).to be true
        end

        load_data.each do |data|
          ConfigurationDummyLoader.load_data({ unfold_sv_interface_port: random_updown_case(data).to_sym })
          c = @factory.create(configuration_file)
          expect(c.unfold_sv_interface_port?).to be true
        end
      end
    end

    context "ロード結果のHashに:unfold_sv_interface_portが含まれていて、値がfalse/nil/off/noのいずれかの場合" do
      let(:load_data) do
        ['false', 'nil', 'off', 'no']
      end

      it "falseを返す" do
        load_data.each do |data|
          ConfigurationDummyLoader.load_data({ unfold_sv_interface_port: random_updown_case(data) })
          c = @factory.create(configuration_file)
          expect(c.unfold_sv_interface_port?).to be false
        end

        load_data.each do |data|
          ConfigurationDummyLoader.load_data({ unfold_sv_interface_port: random_updown_case(data).to_sym })
          c = @factory.create(configuration_file)
          expect(c.unfold_sv_interface_port?).to be false
        end
      end
    end
  end

  context "ロード結果のHashに:unfold_sv_interface_portが含まれていて、値がtrue/false/nil/on/off/yes/no以外の場合" do
    let(:load_data) do
      ["", "foo", 0, 1, 0.0, 1.0, Object.new, []]
    end

    specify "RgGen::ConfigurationErrorを発生させる" do
      load_data.each do |data|
        ConfigurationDummyLoader.load_data({ unfold_sv_interface_port: data })
        expect {
          @factory.create(configuration_file)
        }.to raise_configuration_error "non boolean value; should be true/false/nil/on/off/yes/no: #{data.inspect}"
      end
    end
  end
end
