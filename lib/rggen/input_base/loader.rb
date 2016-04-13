module RgGen
  module InputBase
    class Loader
      class << self
        attr_writer :supported_types

        def acceptable?(file_name)
          ext = File.ext(file_name).to_sym
          @supported_types.any? { |type| type.casecmp(ext) == 0 }
        end
      end
    end
  end
end
