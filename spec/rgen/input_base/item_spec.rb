require_relative  '../../spec_helper'

module RgGen::InputBase
  describe Item do
    let(:owner) do
      Component.new(nil)
    end

    describe ".field" do
      let(:field_name) do
        :foo
      end

      let(:field_value) do
        :field_value
      end

      let(:field_default_value) do
        :field_default_value
      end

      it "引数で与えられたフィールド名のインスタンスメソッドを定義する" do
        f = field_name
        k = Class.new(Item) do
          field f
        end
        expect(k.method_defined?(field_name)).to be true
      end

      context "フィールド名のみ与えられた場合" do
        it "フィールド名のインスタンス変数を返すメソッドを定義する" do
          f = field_name
          v = field_value
          k = Class.new(Item) do
            field f
            define_method(:initialize) do |owner|
              super(owner)
              instance_variable_set("@#{f}", v)
            end
          end
          i = k.new(owner)

          expect(i.send(field_name)).to eq field_value
        end

        context "フィールド名の末尾が'?'のとき" do
          it "フィールド名から'?'を除いたインスタンス変数を返すメソッドを定義する" do
            i = Class.new(Item) {
              field :foo?
              define_method(:initialize) do |owner|
                super(owner)
                @foo  = true
              end
            }.new(owner)

            expect(i).to be_foo
          end
        end
      end

      context "フィールド名とヘルパーメソッドへの委譲設定が与えられた場合" do
        it "同名のヘルパーメソッドへ委譲するメソッドを定義する" do
          k = Class.new(Item) {
            define_helpers {def foo;end}
            field :foo, forward_to_helper:true
          }
          i = k.new(owner)

          expect(k).to receive(:foo).with(no_args)
          i.foo
        end
      end

      context "フィールド名と委譲先のメソッド名が与えられた場合" do
        it "与えたメソッドに委譲するメソッドを定義する" do
          i = Class.new(Item) {
            field :foo, forward_to: :bar
            def bar;end
          }.new(owner)

          expect(i).to receive(:bar).with(no_args)
          i.foo
        end
      end

      context "フィールド名とブロックが与えられた場合" do
        it "ブロックの実行結果を返すメソッドを定義する" do
          f = field_name
          v = field_value
          k = Class.new(Item) do
            field f do
              v
            end
          end
          i = k.new(owner)

          expect(i.send(field_name)).to eq field_value
        end
      end

      context "デフォルト値が与えられて、" do
        context "フィールド名のインスタンス変数がない場合" do
          it "デフォルト値を返すメソッドを定義する" do
            f = field_name
            v = field_default_value
            k = Class.new(Item) do
              field f, default:v
            end
            i = k.new(owner)

            expect(i.send(field_name)).to eq field_default_value
          end
        end

        context "フィールド名のインスタンス変数がある場合" do
          it "フィールド名のインスタンス変数を返すメソッドを定義する" do
            f = field_name
            v = field_value
            d = field_default_value
            k = Class.new(Item) do
              field f, default:d
              define_method(:initialize) do |owner|
                super(owner)
                instance_variable_set("@#{f}", v)
              end
            end
            i = k.new(owner)

            expect(i.send(field_name)).to eq field_value
          end
        end
      end

      context "バリデーションが不必要なフィールドの場合" do
        specify "フィールド呼び出し時に#validateを呼び出さない" do
          i0  = Class.new(Item) {
            field :foo
            build {@foo = :foo}
          }.new(owner)
          i1  = Class.new(Item) {
            field :bar, need_validation:false do
              :bar
            end
          }.new(owner)
          i0.build
          i1.build

          expect(i0).not_to receive(:validate).with(no_args)
          expect(i1).not_to receive(:validate).with(no_args)
          expect(i0.foo).to eq :foo
          expect(i1.bar).to eq :bar
        end
      end

      context "バリデーションが必要なフィールドの場合" do
        specify "フィールド呼び出し時に#validateを呼び出す" do
          i0  = Class.new(Item) {
            field :foo, need_validation:true
            build {@foo = :foo}
          }.new(owner)
          i1  = Class.new(Item) {
            field :bar, need_validation:true do
              :bar
            end
          }.new(owner)
          i0.build
          i1.build

          expect(i0).to receive(:validate).with(no_args)
          expect(i1).to receive(:validate).with(no_args)
          expect(i0.foo).to eq :foo
          expect(i1.bar).to eq :bar
        end
      end
    end

    describe ".active_item?" do
      context ".buildでブロックが登録されている場合" do
        it "真を返す" do
          i0  = Class.new(Item) { build {} }
          i1  = Class.new(i0)
          i2  = Class.new(i1) { build {} }
          expect(i0).to be_active_item
          expect(i1).to be_active_item
          expect(i2).to be_active_item
        end
      end

      context ".buildでブロックが登録されていない場合" do
        it "偽を返す" do
          i0  = Class.new(Item)
          i1  = Class.new(i0)
          expect(i0).not_to be_active_item
          expect(i1).not_to be_active_item
        end
      end
    end

    describe ".passive_item?" do
      context ".buildでブロックが登録されている場合" do
        it "偽を返す" do
          i0  = Class.new(Item) { build {} }
          i1  = Class.new(i0)
          i2  = Class.new(i1) { build {} }
          expect(i0).not_to be_passive_item
          expect(i1).not_to be_passive_item
          expect(i2).not_to be_passive_item
        end
      end

      context ".buildでブロックが登録されていない場合" do
        it "偽を返す" do
          i0  = Class.new(Item)
          i1  = Class.new(i0)
          expect(i0).to be_passive_item
          expect(i1).to be_passive_item
        end
      end
    end

    describe "#fields" do
      it ".fieldで定義されたメソッド一覧を返す" do
        fields  = [:foo, :bar]
        k = Class.new(Item) do
          fields.each do |f|
            field f
          end
        end
        i = k.new(owner)

        expect(i.fields).to match fields
      end

      context "継承されたとき" do
        specify "メソッド一覧は継承先に引き継がれる" do
          k0  = Class.new(Item) do
            field :foo
            field :bar
          end
          k1  = Class.new(k0) do
            field :baz
          end

          i0      = k0.new(owner)
          i1      = k1.new(owner)
          fields  = i0.fields.concat([:baz])
          expect(i1.fields).to match fields
        end
      end
    end

    describe "#build" do
      let(:source) do
        :source
      end

      context ".buildでブロックが登録されているとき" do
        it "登録されたブロックを呼び出してビルドを行う" do
          i = Class.new(Item) {
            field :field
            build do |source|
              @field  = source
            end
          }.new(owner)

          i.build(source)
          expect(i.field).to eq source
        end
      end

      context "継承されたとき" do
        specify "登録されたブロックが継承先に引き継がれる" do
          k0  = Class.new(Item) do
            field :foo
            build {@foo = "foo"}
          end
          k1  = Class.new(k0) do
            field :bar
            build {@bar = "#{@foo}_bar"}
          end
          k2  = Class.new(k1) do
            field :baz
            build {@baz = "#{@bar}_baz"}
          end

          i = k2.new(owner)
          i.build(source)
          expect(i.foo).to eq "foo"
          expect(i.bar).to eq "foo_bar"
          expect(i.baz).to eq "foo_bar_baz"
        end
      end

      context "ビルドブロックが登録されていないとき" do
        it "エラーなく実行される" do
          i = Class.new(Item).new(owner)
          expect{i.build(source)}.not_to raise_error
        end
      end
    end

    describe "#validate" do
      context ".validateでブロックが登録されているとき" do
        it "登録されたブロックを呼び出してバリデートを行う" do
          v = nil
          i = Class.new(Item) {
            validate do
              v = self
            end
          }.new(owner)

          i.validate
          expect(v).to eql i
        end
      end

      context "バリデートブロックが登録されていないとき" do
        it "エラー無く実行できる" do
          i = Class.new(Item).new(owner)
          expect{i.validate}.to_not raise_error
        end
      end

      context "すでに一度#validateが呼び出されている場合" do
        specify "バリデートブロックは実行されない" do
          v = 0
          i = Class.new(Item) {
            validate {v += 1}
          }.new(owner)
          i.validate
          i.validate
          expect(v).to eq 1
        end
      end

      context "継承されたとき" do
        specify "登録されたブロックは継承先に引き継がれる" do
          v   = nil
          k0  = Class.new(Item) do
            validate {v = "foo"}
          end
          k1  = Class.new(k0) do
            validate {v = "#{v}_bar"}
          end
          k2  = Class.new(k1) do
            validate {v = "#{v}_baz"}
          end

          i = k2.new(owner)
          i.validate
          expect(v).to eq "foo_bar_baz"
        end
      end
    end

    describe "#pattern_match" do
      before(:all) do
        owner   = Component.new(nil)
        @items  = []
        @items << Class.new(Item) {
          input_pattern %r{foo(bar)?}
          build { |cell| }
        }.new(owner)
        @items << Class.new(Item) {
          input_pattern %r{foo(bar)?}, match_automatically: true
          build { |cell| }
        }.new(owner)
        @items << Class.new(Item) {
          input_pattern %r{foo(bar)?}, match_automatically: false
          build { |cell| }
        }.new(owner)
        @items << Class.new(Item) {
          input_pattern %r{foo(bar)?}
        }.new(owner)
        @items << Class.new(Item) {
          input_pattern %r{foo-bar}
        }.new(owner)
        @items << Class.new(Item) {
          input_pattern %r{foo-bar}, ignore_blank: true
        }.new(owner)
        @items << Class.new(Item) {
          input_pattern %r{foo-bar}, ignore_blank: false
        }.new(owner)
        @items << Class.new(Item) {
          input_pattern %r{foo}
        }.new(owner)
        @items << Class.new(Item) {
          input_pattern %r{foo}, match_wholly: true
        }.new(owner)
        @items << Class.new(Item) {
          input_pattern %r{foo}, match_wholly: false
        }.new(owner)
        @items << Class.new(Item) {
          input_pattern %r{100}
        }.new(owner)
        @items << Class.new(Item) {
          input_pattern %r{100}, convert_to_string: false
        }.new(owner)
        @items << Class.new(Item) {
          input_pattern %r{100}, convert_to_string: true
        }.new(owner)
        @items << Class.new(@items[0].class).new(owner)
      end

      let(:items) do
        @items
      end

      it ".input_patternで登録された正規表現で一致比較を行う" do
        match_data  = items[0].send(:pattern_match, "foo")
        expect(match_data).to be_instance_of(MatchData)
        expect(match_data[0]).to eq "foo"

        match_data  = items[0].send(:pattern_match, "baz")
        expect(match_data).to be_nil
      end

      specify "#match_dataで直近の比較結果を参照できる" do
        match_data  = items[0].send(:pattern_match, "foo")
        expect(items[0].send(:match_data)).to eql match_data

        items[0].send(:pattern_match, "baz")
        expect(items[0].send(:match_data)).to be_nil
      end

      specify "#pattern_matched?で直近の比較が成功したか参照できる" do
        items[0].send(:pattern_match, "foo")
        expect(items[0].send(:pattern_matched?)).to be true

        items[0].send(:pattern_match, "baz")
        expect(items[0].send(:pattern_matched?)).to be false
      end

      specify "#capturesで直近のキャプチャ文字列を参照できる" do
        items[0].send(:pattern_match, "foo")
        expect(items[0].send(:captures)).to match [nil]

        items[0].send(:pattern_match, "foobar")
        expect(items[0].send(:captures)).to match ["bar"]

        items[0].send(:pattern_match, "baz")
        expect(items[0].send(:captures)).to be_nil
      end

      describe "match_automaticallyオプション" do
        context "match_automaticallyオプションが設定されていないか、trueが設定された場合" do
          it "#build実行に末尾の引数に対して一致比較を行う" do
            expect(items[0]).to receive(:pattern_match).with("bar")
            expect(items[1]).to receive(:pattern_match).with("bar")
            items[0].build("foo", "bar")
            items[1].build("foo", "bar")
          end
        end

        context "match_automaticalyオプションにfalseが設定された場合" do
          it "#build実行に一致比較を行わない" do
            expect(items[2]).not_to receive(:pattern_match)
            items[2].build("foo")
          end
        end

        context "ビルドブロックが登録されていない場合" do
          it "#build実行に一致比較を行わない" do
            expect(items[3]).not_to receive(:pattern_match)
            items[3].build("foo")
          end
        end
      end

      describe "ignore_blankオプション" do
        context "ignore_blankオプションが設定されていないか、trueが設定された場合" do
          it "先頭、末尾、単語と記号間の空白を無視して、一致比較を行う" do
            expect(items[4].send(:pattern_match, "foo-bar"      )).to be_truthy
            expect(items[4].send(:pattern_match, " foo -\tbar\t")).to be_truthy
            expect(items[4].send(:pattern_match, " foo -\nbar\t")).to be_falsey
            expect(items[5].send(:pattern_match, "foo-bar"      )).to be_truthy
            expect(items[5].send(:pattern_match, " foo -\tbar\t")).to be_truthy
            expect(items[5].send(:pattern_match, " foo -\nbar\t")).to be_falsey
          end
        end

        context "ignore_blankオプションにfalseが設定された場合" do
          it "先頭、末尾、単語と記号間の空白を無視せず、一致比較を行う" do
            expect(items[6].send(:pattern_match, "foo-bar"      )).to be_truthy
            expect(items[6].send(:pattern_match, " foo -\tbar\t")).to be_falsey
          end
        end
      end

      describe "match_whollyオプション" do
        context "match_whollyオプションが設定されていないか、trueが設定された場合" do
          it "文字列全体に対する正規表現として一致比較を行う" do
            expect(items[7].send(:pattern_match, "foo"   )).to be_truthy
            expect(items[7].send(:pattern_match, "foobar")).to be_falsey
            expect(items[8].send(:pattern_match, "foo"   )).to be_truthy
            expect(items[8].send(:pattern_match, "foobar")).to be_falsey
          end
        end

        context "match_whollyオプションにfalseが設定された場合" do
          it "通常の正規表現として一致比較を行う" do
            expect(items[9].send(:pattern_match, "foo"   )).to be_truthy
            expect(items[9].send(:pattern_match, "foobar")).to be_truthy
          end
        end
      end

      describe "convert_to_stringオプション" do
        context "convert_to_stringオプションが設定されていないか、falseが設定された場合" do
          it "入力データをそのまま使って一致比較を行う" do
            expect(items[10].send(:pattern_match, 100)).to be_falsey
            expect(items[11].send(:pattern_match, 100)).to be_falsey
          end
        end

        context "convert_to_stringオプションにfalseが設定された場合" do
          it "入力データを文字列に変換して一致比較を行う" do
            expect(items[12].send(:pattern_match, 100)).to be_truthy
          end
        end
      end

      specify ".input_patternで登録されたパターンは継承先に引き継がれる" do
        expect(items[13].send(:pattern_match, "foo")).to be_truthy
      end
    end
  end
end
