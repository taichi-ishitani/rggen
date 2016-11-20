require_relative  '../../spec_helper'

module RgGen
  describe ERBEngine do
    describe "#process_template" do
      let(:engine) do
        ERBEngine.instance
      end

      let(:template_path) do
        [File.ext(File.expand_path(__FILE__), '.erb'), 'bar.erb']
      end

      let(:context) do
        Object.new.tap do |c|
          def c.foo
            'foo'
          end
          def c.bar
            'bar'
          end
        end
      end

      let(:call_info) do
        caller(0).first
      end

      before do
        expect(File).to receive(:read).with(template_path[0]).and_return('<%= foo %>')
        expect(File).to receive(:read).with(template_path[1]).and_return('<%= bar %>')
      end

      it "ERB形式のテンプレートを処理する" do
        expect(engine.process_template(context, nil             , call_info)).to eq 'foo'
        expect(engine.process_template(context, template_path[1], call_info)).to eq 'bar'
      end
    end
  end
end
