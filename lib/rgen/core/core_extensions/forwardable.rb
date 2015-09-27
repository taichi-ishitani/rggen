require 'forwardable'
module SingleForwardable
  def def_object_delegator(target, method, ali = method)
    define_singleton_method(ali) do |*args, &block|
      target.__send__(method, *args, &block)
    end
  end

  def def_object_delegators(target, *methods)
    methods.each do |method|
      def_object_delegator(target, method)
    end
  end
end
