module RegisterGenerator
  module InputBase
    include RegisterGenerator
  end
end

require_relative  'input_base/component'
require_relative  'input_base/item'
require_relative  'input_base/loader'
require_relative  'input_base/component_factory'
