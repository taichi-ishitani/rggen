require_relative  '../../../spec_helper'

module RGen::InputBase
  describe Item do
    let(:owner) do
      Component.new
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

      context "継承されたとき" do
        specify "登録されたブロックは継承先に引き継がれる" do
          v   = nil
          k0  = Class.new(Item) do
            validate {v = 0}
          end
          k1  = Class.new(k0) do
            validate {v += 1}
          end
          k2  = Class.new(k1) do
            validate {v += 2}
          end

          i = k2.new(owner)
          i.validate
          expect(v).to eq 3
        end
      end

      context "バリデートブロックが登録されていないとき" do
        it "エラー無く実行できる" do
          i = Class.new(Item).new(owner)
          expect{i.validate}.to_not raise_error
        end
      end
    end
  end
end
