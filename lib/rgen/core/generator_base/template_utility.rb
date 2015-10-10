module RGen::GeneratorBase
  module TemplateUtility
    require 'baby_erubis'

    module Extensions
      def template_engine(path)
        @template_engines       ||= {}
        @template_engines[path] ||= create_engine(path)
      end

      private

      def create_engine(path)
        template  = File.read(path)
        BabyErubis::Text.new.from_str(template, path)
      end
    end

    def self.included(klass)
      klass.extend(Extensions)
    end

    def process_template(path = nil)
      path  ||= File.ext(caller.first[/^(.+?):\d/, 1], 'erb')
      template_engine(path).render(self)
    end

    private

    def template_engine(path)
      self.class.template_engine(path)
    end
  end
end
