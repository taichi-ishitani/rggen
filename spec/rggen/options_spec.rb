require_relative '../spec_helper'

module RgGen
  describe Options do
    let(:options) do
      Options.new
    end

    describe "#parse" do
      let(:args) do
        [
          [],
          ['foo', 'bar'],
          ['-c foo.yaml', 'foo', 'bar'],
          ['-c', 'foo.yaml', 'foo', 'bar', '-o', 'bar']
        ]
      end

      it "解析済みの引数を取り除く" do
        options.parse(args[0])
        expect(args[0]).to match []

        options.parse(args[1])
        expect(args[1]).to match ['foo', 'bar']

        options.parse(args[2])
        expect(args[2]).to match ['foo', 'bar']

        options.parse(args[3])
        expect(args[3]).to match ['foo', 'bar']
      end
    end
  end
end
