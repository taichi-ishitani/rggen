class Integer
  def pow2?
    return false unless positive?
    ((ord & pred) == 0) ? true : false
  end
end
