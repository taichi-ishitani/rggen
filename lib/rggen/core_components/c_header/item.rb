module RgGen
  module CHeader
    class Item < OutputBase::Item
      include         CUtility
      template_engine ERBEngine
    end
  end
end
