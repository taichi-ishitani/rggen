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
        item  = klass.new(generator, nil, nil)
        generator.add_item(item)
      end
      parent.add_child(generator) unless parent.nil?
      generator
    end

    before(:all) do
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
  end
end
