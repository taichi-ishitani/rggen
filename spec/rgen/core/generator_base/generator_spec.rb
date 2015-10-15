require_relative '../../../spec_helper'

module RGen::GeneratorBase
  describe Generator do
    class FooItem < Item
      generate_code :foo do |buffer|
        buffer  << "#{generator.object_id}_foo"
      end
    end

    class BarItem < Item
      generate_code :bar do |buffer|
        buffer  << "#{generator.object_id}_bar"
      end
    end

    def create_generator(parent = nil)
      generator = Generator.new
      [FooItem, BarItem].each do |klass|
        item  = klass.new(generator)
        generator.add_item(item)
      end
      parent.add_child(generator) unless parent.nil?
      generator
    end

    before do
      @generator        = create_generator
      @child_generators = 2.times.map do
        create_generator(@generator)
      end
      @grandchild_generators  = 4.times.map do |i|
        create_generator(@child_generators[i / 2])
      end
    end

    let(:generator) do
      @generator
    end

    let(:child_generators) do
      @child_generators
    end

    let(:grandchild_generators) do
      @grandchild_generators
    end

    describe "#generate_code" do
      let(:buffer) do
        []
      end

      it "kindで指定した種類のコードを生成する" do
        generator.generate_code(:foo, :top_down, buffer)
        expect(buffer).to match [
          "#{generator.object_id}_foo",
          "#{child_generators[0].object_id}_foo",
          "#{grandchild_generators[0].object_id}_foo",
          "#{grandchild_generators[1].object_id}_foo",
          "#{child_generators[1].object_id}_foo",
          "#{grandchild_generators[2].object_id}_foo",
          "#{grandchild_generators[3].object_id}_foo"
        ]
      end

      context "modeが:top_downを指定した場合" do
        it "上位からコードの生成を行う" do
          generator.generate_code(:foo, :top_down, buffer)
          expect(buffer).to match [
            "#{generator.object_id}_foo",
            "#{child_generators[0].object_id}_foo",
            "#{grandchild_generators[0].object_id}_foo",
            "#{grandchild_generators[1].object_id}_foo",
            "#{child_generators[1].object_id}_foo",
            "#{grandchild_generators[2].object_id}_foo",
            "#{grandchild_generators[3].object_id}_foo"
          ]
        end
      end

      context "modeが:bottom_upを指定した場合" do
        it "下位からコードの生成を行う" do
          generator.generate_code(:foo, :bottom_up, buffer)
          expect(buffer).to match [
            "#{grandchild_generators[0].object_id}_foo",
            "#{grandchild_generators[1].object_id}_foo",
            "#{child_generators[0].object_id}_foo",
            "#{grandchild_generators[2].object_id}_foo",
            "#{grandchild_generators[3].object_id}_foo",
            "#{child_generators[1].object_id}_foo",
            "#{generator.object_id}_foo"
          ]
        end
      end
    end

    describe "#write_file" do
      before do
        generator.items.each do |item|
          expect(item).to receive(:write_file).with(output_directory)
        end
        child_generators.map(&:items).flatten.each do |item|
          expect(item).to receive(:write_file).with(output_directory)
        end
        grandchild_generators.map(&:items).flatten.each do |item|
          expect(item).to receive(:write_file).with(output_directory)
        end
      end

      context "出力ディレクトリが指定されていない場合" do
        let(:output_directory) do
          ''
        end

        it "空文字列を引数として、配下全アイテムオブジェクトの#write_fileを呼び出す" do
          generator.write_file
        end
      end

      context "出力ディレクトリが指定された場合" do
        let(:output_directory) do
          '/foo/bar'
        end

        it "与えられた出力ディレクトリを引数として、配下全アイテムオブジェクトの#write_fileを呼び出す" do
          generator.write_file(output_directory)
        end
      end
    end

    describe "#create_context" do
      let(:child_contexts) do
        child_generators.map {|child_generator| child_generator.context}
      end

      let(:grandchild_contexts) do
        grandchild_generators.map {|grandchild_generator| grandchild_generator.context}
      end

      it "自身及び配下のジェネレータでコンテキストオブジェクトを作成する" do
        generator.create_context
        expect(generator.context  ).to be_kind_of(Context)
        expect(child_contexts     ).to all(be_kind_of(Context))
        expect(grandchild_contexts).to all(be_kind_of(Context))
      end

      specify "生成されたコンテキストの#levelは属するジェネレータの#levelと同じ値を取る" do
        generator.create_context
        expect(generator.context.level         ).to eq generator.level
        expect(     child_contexts.map(&:level)).to all(eq      child_generators[0].level)
        expect(grandchild_contexts.map(&:level)).to all(eq grandchild_generators[0].level)
      end
    end
  end
end
