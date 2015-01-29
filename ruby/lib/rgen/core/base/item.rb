class RGen::Base::Item
  def initialize(owner)
    @owner  = owner
  end

  attr_reader :owner
end
