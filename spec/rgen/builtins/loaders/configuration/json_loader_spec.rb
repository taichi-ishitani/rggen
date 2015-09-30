require_relative '../../spec_helper'

describe 'json_loader' do
  include_context 'configuration common'

  before(:all) do
    RGen.enable(:global, [:address_width, :data_width])
    @factory  = RGen.builder.build_factory(:configuration)
  end

  after(:all) do
    clear_enabled_items
  end

  it "拡張子がjsonのJSONフォーマットのファイルをロードする" do
    c = @factory.create(File.join(__dir__, "files", "sample.json"))
    expect(c).to match_address_width(16)
    expect(c).to match_data_width(64)
  end
end
