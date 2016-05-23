require_relative '../../spec_helper'

RSpec::Matchers.define :have_cell do |file, sheet, row, column, field_values|
  match do |component|
    return false unless component.kind_of?(RgGen::InputBase::Component)

    expected_position = RgGen::RegisterMap::GenericMap::Cell::Position.new(file, sheet, row, column)
    component.items.each do |item|
      actual_position   = item.instance_variable_get(:@position)
      next unless actual_position == expected_position
      next unless item.fields.size == field_values.size
      next unless field_values.keys.all? {|field| item.fields.include?(field)}
      return true if field_values.all? {|field, value| item.send(field) == value}
    end

    false
  end
end
