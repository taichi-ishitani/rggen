RSpec.configure do |config|
  config.before(:each) do
    allow(FileUtils).to receive(:mkpath)
  end
end
