loader(:configuration, :json) do
  require 'json'

  def load_file(file)
    JSON.parse(File.read(file))
  end
end
