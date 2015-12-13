require_relative '../spec_helper'

module RGen
  describe Generator do
    let(:generator) do
      Generator.new
    end

    describe "options" do
      before do
        $stdout = StringIO.new
        $stderr = StringIO.new
      end

      after do
        $stdout = STDOUT
        $stderr = STDERR
      end

      describe "-v/--version" do
        it "バージョンを出力し、そのまま終了する" do
          expect {
            generator.run(['-v'])
          }.to raise_error SystemExit
          expect {
            generator.run(['--version'])
          }.to raise_error SystemExit
          expect($stdout.string).to eq("rgen #{RGen::VERSION}\n" * 2)
        end
      end

      describe "--setup" do
        after do
          clear_enabled_items
        end

        context "セットアップファイルの指定が無い場合" do
          before do
            expect(RGen.builder).to receive(:enable).with(:global, [:data_width, :address_width]).and_call_original
            expect(RGen.builder).to receive(:enable).with(:register_block, [:name, :byte_size]).and_call_original
            expect(RGen.builder).to receive(:enable).with(:register, [:offset_address, :name, :accessibility]).and_call_original
            expect(RGen.builder).to receive(:enable).with(:bit_field, [:bit_assignment, :name, :type, :initial_value, :reference]).and_call_original
            expect(RGen.builder).to receive(:enable).with(:bit_field, :type, [:rw, :ro, :reserved]).and_call_original
            expect(RGen.builder).to receive(:enable).with(:register_block, [:module_declaration, :port_declarations, :signal_declarations, :clock_reset, :host_if, :response_mux]).and_call_original
            expect(RGen.builder).to receive(:enable).with(:register_block, :host_if, [:apb]).and_call_original
          end

          it "デフォルトのセットアップが実行される" do
            expect {
              generator.run([])
            }.not_to raise_error
          end
        end

        context "セットアップファイルの指定がある場合" do
          before do
            expect(RGen.builder).to receive(:define_list_item).with(:bit_field, :type, :foo).and_call_original
            expect(RGen.builder).to receive(:define_list_item).with(:register_block, :host_if, :bar).and_call_original
            expect(RGen.builder).to receive(:enable).with(:global, [:data_width, :address_width]).and_call_original
            expect(RGen.builder).to receive(:enable).with(:register_block, [:name, :base_address]).and_call_original
            expect(RGen.builder).to receive(:enable).with(:register, [:offset_address, :name, :accessibility]).and_call_original
            expect(RGen.builder).to receive(:enable).with(:bit_field, [:bit_assignment, :name, :type, :initial_value, :reference]).and_call_original
            expect(RGen.builder).to receive(:enable).with(:bit_field, :type, [:rw, :ro, :foo, :reserved]).and_call_original
            expect(RGen.builder).to receive(:enable).with(:register_block, [:module_declaration, :port_declarations, :signal_declarations, :clock_reset, :host_if, :response_mux]).and_call_original
            expect(RGen.builder).to receive(:enable).with(:register_block, :host_if, [:apb, :bar]).and_call_original
          end

          after do
            clear_dummy_list_items(:type   , [:foo])
            clear_dummy_list_items(:host_if, [:bar])
          end

          let(:setup_file) do
            "#{__dir__}/files/sample_setup.rb"
          end

          it "--setupで指定したファイルからセットアップが実行される" do
            expect {
              generator.run(["--setup", setup_file])
            }.not_to raise_error
          end
        end
      end

      describe "-c/--configuration" do
        let(:configuration_factory) do
          f = RGen.builder.build_factory(:configuration)
          allow(RGen.builder).to receive(:build_factory).and_wrap_original do |m, *args|
            if args[0] == :configuration
              f
            else
              m.call(*args)
            end
          end
          f
        end

        context "コンフィグレーションファイルの指定が無い場合" do
          before do
            expect(configuration_factory).to receive(:create).with(nil).and_call_original
          end

          it "デフォルト値でコンフィグレーションを生成する" do
            expect {
              generator.run([])
            }.not_to raise_error
          end
        end

        context "コンフィグレーションファイルの指定が無い場合" do
          before do
            expect(configuration_factory).to receive(:create).with(sample_yaml).and_call_original
            expect(configuration_factory).to receive(:create).with(sample_json).and_call_original
          end

          let(:sample_yaml) do
            "#{__dir__}/files/sample.yaml"
          end

          let(:sample_json) do
            "#{__dir__}/files/sample.json"
          end

          it "指定したファイルからコンフィグレーションを生成する" do
            expect {
              generator.run(["-c", sample_yaml])
            }.not_to raise_error
            expect {
              generator.run(["--configuration", sample_json])
            }.not_to raise_error
          end
        end
      end
    end
  end
end
