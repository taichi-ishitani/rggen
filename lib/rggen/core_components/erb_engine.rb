module RgGen
  class ERBEngine < OutputBase::TemplateEngine
    def file_extension
      :erb
    end

    def parse_template(path)
      Erubi::Engine.new(File.read(path), filename: path)
    end

    def render(context, template)
      context.instance_eval(template.src, template.filename, 1)
    end
  end
end
