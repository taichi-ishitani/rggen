require 'forwardable'
require 'baby_erubis'

require_relative 'core/core_extensions/facets'
require_relative 'core/core_extensions/forwardable'
require_relative 'core/core_extensions/integer'

require_relative 'core/exceptions'

require_relative 'core/builder/simple_item_entry'
require_relative 'core/builder/list_item_entry'
require_relative 'core/builder/item_store'
require_relative 'core/builder/component_entry'
require_relative 'core/builder/component_store'
require_relative 'core/builder/input_component_store'
require_relative 'core/builder/category'
require_relative 'core/builder/builder'
require_relative 'core/builder/commands'

require_relative 'core/base/hierarchical_structure'
require_relative 'core/base/hierarchical_accessors'
require_relative 'core/base/hierarchical_item_accessors'
require_relative 'core/base/component'
require_relative 'core/base/item'
require_relative 'core/base/component_factory'
require_relative 'core/base/item_factory'

require_relative 'core/input_base/component'
require_relative 'core/input_base/item'
require_relative 'core/input_base/loader'
require_relative 'core/input_base/component_factory'
require_relative 'core/input_base/item_factory'

require_relative 'core/configuration/raise_error'
require_relative 'core/configuration/item'
require_relative 'core/configuration/configuration_factory'
require_relative 'core/configuration/item_factory'
require_relative 'core/configuration/setup'

require_relative 'core/register_map/generic_map'
require_relative 'core/register_map/loader'
require_relative 'core/register_map/component'
require_relative 'core/register_map/item'
require_relative 'core/register_map/register_map_factory'
require_relative 'core/register_map/register_block_factory'
require_relative 'core/register_map/register_factory'
require_relative 'core/register_map/bit_field_factory'
require_relative 'core/register_map/item_factory'
require_relative 'core/register_map/setup'

require_relative 'core/output_base/template_utility'
require_relative 'core/output_base/component'
require_relative 'core/output_base/item'
require_relative 'core/output_base/component_factory'
require_relative 'core/output_base/item_factory'

require_relative 'core/rtl/verilog/identifier'
require_relative 'core/rtl/verilog/signal_declaration'
require_relative 'core/rtl/verilog/port_declaration'
require_relative 'core/rtl/verilog/parameter_declaration'
