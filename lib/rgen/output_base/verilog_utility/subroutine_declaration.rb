module RGen
  module OutputBase
    module VerilogUtility
      class SubroutineDeclaration < StructureDeclaration
        def initialize(type, name, &body)
          @type = type
          super(name, &body)
        end

        def return_type(data_type_and_width)
          if [Symbol, String].any?(&data_type_and_width.method(:is_a?))
            @return_type  = data_type_and_width
          else
            data_type     = data_type_and_width[:data_type]
            width         = data_type_and_width[:width    ] || 1
            @return_type  =
              ((width > 1) && "#{data_type} [#{width - 1}:0]") || data_type
          end
        end

        def arguments(args)
          @arguments  = args
        end

        private

        def code
          self
        end

        def function?
          @type == :function
        end

        def header_code(name)
          [
            (function? && :function   ) || :task,
            (function? && @return_type) || nil,
            "#{name}(#{Array(@arguments).join(', ')});"
          ].compact.join(' ')
        end

        def footer_code
          (function? && :endfunction) || :endtask
        end
      end
    end
  end
end