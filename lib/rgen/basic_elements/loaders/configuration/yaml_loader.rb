RGen.loader(:configuration, [:yml, :yaml]) do
  require 'yaml'

  def load_file(file)
    YAML.load_file(file)
  end
end
