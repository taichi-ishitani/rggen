module RGen
  module InputBase
    class Item < Base::Item
      include RegxpPatterns

      class InputMatcher
        def initialize(pattern, options)
          @options  = options
          @pattern  =
            if @options.fetch(:match_wholly, true)
              /\A#{pattern}\z/
            else
              pattern
            end
        end

        attr_reader :match_data

        def match_automatically?
          @options.fetch(:match_automatically, true)
        end

        def match(rhs)
          rhs = rhs.to_s if @options[:convert_to_string]
          rhs = delete_blanks(rhs) if @options.fetch(:ignore_blank, true)
          @match_data =
            case rhs
            when @pattern
              Regexp.last_match
            end
        end

        private

        BLANK_REGEXP  = [
          /\A[ \t]+/,
          /(?<=\w)[ \t]+(?=[[:punct:]])/,
          /(?<=[[:punct:]])[ \t]+(?=\w)/,
          /[ \t]+\z/
        ].inject(&:|).freeze

        def delete_blanks(rhs)
          return rhs unless rhs.respond_to?(:gsub)
          rhs.gsub(BLANK_REGEXP, '')
        end
      end

      define_helpers do
        attr_reader :builders
        attr_reader :validators
        attr_reader :input_matcher

        def field(field_name, options = {}, &body)
          return if fields.include?(field_name)

          define_method(field_name) do
            field_method(field_name, options, body)
          end

          fields  << field_name
        end

        def fields
          @fields ||= []
        end

        def build(&body)
          @builders ||= []
          @builders << body
        end

        def validate(&body)
          @validators ||= []
          @validators << body
        end

        def input_pattern(pattern, options = {})
          @input_matcher  = InputMatcher.new(pattern, options)
        end

        def active_item?
          !passive_item?
        end

        def passive_item?
          @builders.nil? || @builders.empty?
        end
      end

      def self.inherited(subclass)
        [:@fields, :@builders, :@validators].each do |v|
          subclass.inherit_class_instance_variable(v, self, &:dup)
        end
        subclass.inherit_class_instance_variable(:@input_matcher, self)
      end

      class_delegator :fields
      class_delegator :builders
      class_delegator :validators
      class_delegator :input_matcher

      def build(*sources)
        return unless builders
        pattern_match(sources.last) if match_automatically?
        builders.each do |builder|
          instance_exec(*sources, &builder)
        end
      end

      def validate
        return if @validated
        return unless validators
        validators.each do |validator|
          instance_exec(&validator)
        end
        @validated  = true
      end

      private

      def pattern_match(rhs)
        input_matcher && input_matcher.match(rhs)
      end

      def match_data
        input_matcher && input_matcher.match_data
      end

      def pattern_matched?
        match_data.not_nil?
      end

      def captures
        match_data && match_data.captures
      end

      def match_automatically?
        input_matcher && input_matcher.match_automatically?
      end

      def field_method(field_name, options, body)
        validate if options[:need_validation]
        if body
          instance_exec(&body)
        elsif options[:forward_to_helper]
          self.class.__send__(field_name)
        elsif options.key?(:forward_to)
          __send__(options[:forward_to])
        else
          default_field_method(field_name, options[:default])
        end
      end

      def default_field_method(field_name, default_value)
        variable_name =
          if field_name =~ /\A([a-zA-Z0-9]\w*)\?\z/
            Regexp.last_match[1].variablize
          else
            field_name.variablize
          end

        if instance_variable_defined?(variable_name)
          instance_variable_get(variable_name)
        else
          default_value
        end
      end
    end
  end
end
