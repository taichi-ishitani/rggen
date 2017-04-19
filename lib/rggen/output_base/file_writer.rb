module RgGen
  module OutputBase
    class FileWriter
      def initialize(pattern, body)
        @pattern  = BabyErubis::Text.new.from_str(pattern)
        @body     = body
      end

      def write_file(context, output_directory = nil)
        path  = generate_path(context, output_directory)
        code  = generate_code(context, path)
        create_output_directory(path)
        File.binwrite(path, code)
      end

      private

      def generate_path(context, output_directory)
        [
          *Array(output_directory), @pattern.render(context)
        ].map(&:to_s).reject(&:empty?).to_path
      end

      def generate_code(context, path)
        context.create_blank_file(path).tap do |file|
          context.instance_exec(file, &@body)
        end
      end

      def create_output_directory(path)
        dirname = path.dirname
        dirname.directory? || dirname.mkpath
      end
    end
  end
end
