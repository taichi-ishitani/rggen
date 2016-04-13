class Integer
  def pow2?
    positive? && (ord & pred).zero?
  end
end
