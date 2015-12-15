require_relative '../spec_helper'

module RGen
  describe Generator do
    before do
      cache   = factory_cache
      plugin  = factory_plugin
      allow(RGen.builder).to receive(:build_factory).and_wrap_original do |m, component_name|
        f     = m.call(component_name)
        mock  = allow(f)
        if plugin.key?(component_name)
          mock.to receive(:create).and_wrap_original(&plugin[component_name])
        else
          mock.to receive(:create).and_call_original
        end
        cache[component_name] << f
        f
      end
    end

    after do
      clear_enabled_items
    end

    let(:generator) do
      Generator.new
    end

    let(:factory_cache) do
      Hash.new do |hash, component_name|
        hash[component_name]  = []
      end
    end

    let(:factory_plugin) do
      {}
    end

    let(:sample_setup) do
      "#{__dir__}/files/sample_setup.rb"
    end

    let(:sample_yaml) do
      "#{__dir__}/files/sample.yaml"
    end

    let(:sample_json) do
      "#{__dir__}/files/sample.json"
    end

    let(:sample_register_maps) do
      ["#{__dir__}/files/sample.xls", "#{__dir__}/files/sample.xlsx", "#{__dir__}/files/sample.csv"]
    end

    describe "バージョンの出力" do
      before do
        $stdout = StringIO.new
        $stderr = StringIO.new
      end

      after do
        $stdout = STDOUT
        $stderr = STDERR
      end

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

    describe "ジェネレータのセットアップ" do
      context "--setupでセットアップファイルの指定が無い場合" do
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
            generator.run([sample_register_maps[0]])
          }.not_to raise_error
        end
      end

      context "--setupでセットアップファイルの指定がある場合" do
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

        it "--setupで指定したファイルからセットアップが実行される" do
          expect {
            generator.run(["--setup", sample_setup, sample_register_maps[1]])
          }.not_to raise_error
        end
      end
    end

    describe "コンフィグレーションの読み出し" do
      context "-c/--configurationでコンフィグレーションファイルの指定が無い場合" do
        it "デフォルト値でコンフィグレーションを生成する" do
          expect {
            generator.run([sample_register_maps[0]])
          }.not_to raise_error
          expect(factory_cache[:configuration][0]).to have_received(:create).with(nil)
        end
      end

      context "-c/--configurationでコンフィグレーションファイルの指定が無い場合" do
        it "指定したファイルからコンフィグレーションを生成する" do
          expect {
            generator.run(["-c", sample_yaml, sample_register_maps[0]])
          }.not_to raise_error
          expect(factory_cache[:configuration][0]).to have_received(:create).with(sample_yaml)
          clear_enabled_items

          expect {
            generator.run(["--configuration", sample_json, sample_register_maps[0]])
          }.not_to raise_error
          expect(factory_cache[:configuration][1]).to have_received(:create).with(sample_json)
        end
      end
    end

    describe "レジスタマップの読み出し" do
      before do
        cache = configuration_cache
        factory_plugin[:configuration]  = proc do |m, *args|
          cache << m.call(*args)
          cache.last
        end
      end

      let(:configuration_cache) do
        []
      end

      it "オプション解析後の先頭の引数をレジスタマップとして読み出す" do
        expect {
          generator.run(['-c', sample_yaml, sample_register_maps[0]])
        }.not_to raise_error
        expect(factory_cache[:register_map][0]).to have_received(:create).with(configuration_cache[0], sample_register_maps[0])
        clear_enabled_items

        expect {
          generator.run(['--setup', sample_setup, sample_register_maps[1]])
        }.not_to raise_error
        expect(factory_cache[:register_map][1]).to have_received(:create).with(configuration_cache[1], sample_register_maps[1])
        clear_enabled_items

        expect {
          generator.run([sample_register_maps[2]])
        }.not_to raise_error
        expect(factory_cache[:register_map][2]).to have_received(:create).with(configuration_cache[2], sample_register_maps[2])
      end
    end
  end
end
