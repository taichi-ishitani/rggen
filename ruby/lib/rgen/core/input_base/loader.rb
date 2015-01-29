class RGen::InputBase::Loader
  def self.support_types(*types)
    @support_types  ||= []
    @support_types.concat(types)
    @support_types
  end

  def self.acceptable?(file_name)
    extension = File.extname(file_name)
    @support_types.any? {|type| extension == ".#{type}"}
  end
end
