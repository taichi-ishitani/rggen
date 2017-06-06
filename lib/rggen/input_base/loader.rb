module RgGen
  module InputBase
    class Loader
      class << self
        attr_writer :supported_types

        def acceptable?(file)
          ext = File.ext(file).to_sym
          @supported_types.any? { |type| type.casecmp(ext).zero? }
        end

        def load(file)
          new.load(file)
        end
      end

      def load(file)
        return load_file(file) if File.exist?(file)
        raise RgGen::LoadError, "cannot load such file -- #{file}"
      end
    end
  end
end
