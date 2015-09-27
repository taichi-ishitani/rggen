module RGen::Base
  class Item
    def initialize(owner)
      @owner  = owner
    end

    attr_reader :owner

    def self.define_helpers(&body)
      singleton_class.class_exec(&body) if block_given?
    end
  end
end
