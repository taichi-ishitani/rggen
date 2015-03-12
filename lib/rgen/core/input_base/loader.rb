module RGen::InputBase
  class Loader
    def self.support_types(type_or_types = nil)
      @support_types  ||= []
      @support_types.concat(Array(type_or_types)) unless type_or_types.nil?
      @support_types
    end

    def self.acceptable?(file_name)
      support_types.include?(File.ext(file_name).to_sym)
    end
  end
end
