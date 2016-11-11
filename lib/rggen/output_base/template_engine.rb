module RgGen
  module OutputBase
    class TemplateEngine
      include Singleton

      def process_template(context, path = nil, call_info = nil)
        path  ||= extract_template_path(call_info || caller[0])
        render(context, templates[path])
      end

      private

      def templates
        @templates  ||= Hash.new do |t, p|
          t[p]  = parse_template(p)
        end
      end

      def extract_template_path(call_info)
        File.ext(call_info[/^(.+?):\d/, 1], file_extension.to_s)
      end
    end
  end
end
