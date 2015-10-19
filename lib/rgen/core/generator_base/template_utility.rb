module RGen
  module GeneratorBase
    module TemplateUtility
      module Extensions
        def template_engines
          @template_engines ||= Hash.new do |engines, path|
            engines[path] = create_engine(path)
          end
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
        self.class.template_engines[path].render(self)
      end
    end
  end
end
