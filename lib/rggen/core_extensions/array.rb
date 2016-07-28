class Array
  def find_by(conditions)
    find do |i|
      conditions.all? do |key, value|
        i.respond_to?(key) && (i.__send__(key) == value)
      end
    end
  end
end
