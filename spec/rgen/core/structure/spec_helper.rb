require_relative  '../../../spec_helper'

shared_context 'structured components' do
  class DummyRegisterMap < RGen::Base::Component
    include RGen::Structure::RegisterMap::Component
  end

  class DummyRegisterBlock < RGen::Base::Component
    include RGen::Structure::RegisterBlock::Component
  end

  class DummyRegister < RGen::Base::Component
    include RGen::Structure::Register::Component
  end

  class DummyBitField < RGen::Base::Component
    include RGen::Structure::BitField::Component
  end

  let(:register_map) do
    DummyRegisterMap.new
  end

  let(:register_block) do
    DummyRegisterBlock.new(register_map)
  end

  let(:register) do
    DummyRegister.new(register_block)
  end

  let(:bit_field) do
    DummyBitField.new(register)
  end
end
