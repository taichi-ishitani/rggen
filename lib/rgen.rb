module RGen
  RGEN_HOME = File.realpath(File.join(__dir__, '..'))

  require 'forwardable'
  require 'baby_erubis'
  require 'fileutils'
  require 'optparse'

  require_relative 'rgen/version'

  require_relative 'rgen/exceptions'

  require_relative 'rgen/core_extensions/facets'
  require_relative 'rgen/core_extensions/forwardable'
  require_relative 'rgen/core_extensions/integer'
  require_relative 'rgen/core_extensions/math'

  require_relative 'rgen/base/hierarchical_accessors'
  require_relative 'rgen/base/hierarchical_item_accessors'
  require_relative 'rgen/base/component'
  require_relative 'rgen/base/item'
  require_relative 'rgen/base/component_factory'
  require_relative 'rgen/base/item_factory'

  require_relative 'rgen/input_base/regexp_patterns'
  require_relative 'rgen/input_base/component'
  require_relative 'rgen/input_base/item'
  require_relative 'rgen/input_base/loader'
  require_relative 'rgen/input_base/component_factory'
  require_relative 'rgen/input_base/item_factory'

  require_relative 'rgen/output_base/line'
  require_relative 'rgen/output_base/code_block'
  require_relative 'rgen/output_base/code_utility'
  require_relative 'rgen/output_base/template_utility'
  require_relative 'rgen/output_base/verilog_utility/identifier'
  require_relative 'rgen/output_base/verilog_utility/variable_declaration'
  require_relative 'rgen/output_base/verilog_utility/structure_declaration'
  require_relative 'rgen/output_base/verilog_utility/module_declaration'
  require_relative 'rgen/output_base/verilog_utility/subroutine_declaration'
  require_relative 'rgen/output_base/verilog_utility'
  require_relative 'rgen/output_base/component'
  require_relative 'rgen/output_base/item'
  require_relative 'rgen/output_base/component_factory'
  require_relative 'rgen/output_base/item_factory'

  require_relative 'rgen/builder/simple_item_entry'
  require_relative 'rgen/builder/list_item_entry'
  require_relative 'rgen/builder/item_store'
  require_relative 'rgen/builder/component_entry'
  require_relative 'rgen/builder/component_store'
  require_relative 'rgen/builder/input_component_store'
  require_relative 'rgen/builder/output_component_store'
  require_relative 'rgen/builder/category'
  require_relative 'rgen/builder/builder'

  require_relative 'rgen/generator'

  require_relative 'rgen/commands'

  require_relative 'rgen/core_components'
  require_relative 'rgen/builtins'
end
