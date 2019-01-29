require_relative '../spec_helper'

describe 'global/array_port_format' do
  include_context 'configuration common'

  before(:all) do
    RgGen.enable(:global, :array_port_format)
    @factory  = build_configuration_factory
  end

  after(:all) do
    clear_enabled_items
  end

  describe "#array_port_format" do
    context "ロード結果のHashに:array_port_formatが含まれないとき" do
      it ":unpackedを返す" do
        ConfigurationDummyLoader.load_data({})
        c = @factory.create(configuration_file)
        expect(c.array_port_format).to eq :unpacked
      end
    end

    context "ロード結果のHashに:array_port_formatが含まれていて、nilの場合" do
      it ":unpackedを返す" do
        ConfigurationDummyLoader.load_data({ array_port_format: nil })
        c = @factory.create(configuration_file)
        expect(c.array_port_format).to be :unpacked
      end
    end

    context "ロード結果のHashに:array_port_formatが含まれていて、値がunpakced場合" do
      it ":unpackedを返す" do
        ConfigurationDummyLoader.load_data({ array_port_format: random_updown_case('unpacked') })
        c = @factory.create(configuration_file)
        expect(c.array_port_format).to be :unpacked

        ConfigurationDummyLoader.load_data({ array_port_format: random_updown_case('unpacked').to_sym })
        c = @factory.create(configuration_file)
        expect(c.array_port_format).to be :unpacked
      end
    end

    context "ロード結果のHashに:array_port_formatが含まれていて、値がvectored場合" do
      it ":vectoredを返す" do
        ConfigurationDummyLoader.load_data({ array_port_format: random_updown_case('vectored') })
        c = @factory.create(configuration_file)
        expect(c.array_port_format).to be :vectored

        ConfigurationDummyLoader.load_data({ array_port_format: random_updown_case('vectored').to_sym })
        c = @factory.create(configuration_file)
        expect(c.array_port_format).to be :vectored
      end
    end

    context "ロード結果のHashに:array_port_formatが含まれていて、値がunpacked/vectored以外の場合" do
      let(:load_data) do
        ["vector", "unpack", "packed", "", "foo", 0, 1, 0.0, 1.0, Object.new, []]
      end

      specify "RgGen::ConfigurationErrorを発生させる" do
        load_data.each do |data|
          ConfigurationDummyLoader.load_data({ array_port_format: data })
          expect {
            @factory.create(configuration_file)
          }.to raise_configuration_error "invalid array port format; should be 'unpacked' or 'vectored': #{data.inspect}"
        end
      end
    end
  end
end
