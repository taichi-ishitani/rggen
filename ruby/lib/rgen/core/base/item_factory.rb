class RGen::Base::ItemFactory
  def register(name, item)
    @target_item  = item  unless @target_item
  end

  def create(owner, *args)
    create_item(owner, *args)
  end

  private

  def create_item(owner, *args)
    @target_item.new(owner)
  end
end
