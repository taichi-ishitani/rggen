module RgGen
  require 'baby_erubis'

  class ERBEngine < OutputBase::TemplateEngine
    def file_extension
      :erb
    end

    def parse_template(path)
      BabyErubis::Text.new.from_str(File.read(path), path)
    end

    def render(context, template)
      template.render(context)
    end
  end
end
