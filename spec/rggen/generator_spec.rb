require_relative '../spec_helper'

module RgGen
  describe Generator do
    before(:all) do
      @expected_rtl_code  = 2.times.map do |i|
        File.read("#{RGGEN_HOME}/sample/sample_#{i}.sv")
      end
      @expected_ral_code  = 2.times.map do |i|
        File.read("#{RGGEN_HOME}/sample/sample_#{i}_ral_pkg.sv")
      end
      @expected_c_header_code = 2.times.map do |i|
        File.read("#{RGGEN_HOME}/sample/sample_#{i}.h")
      end
    end

    before do
      cache   = factory_cache
      plugin  = factory_plugin
      allow(RgGen.builder).to receive(:build_factory).and_wrap_original do |m, component_name|
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

    let(:default_setup) do
      "#{RGGEN_HOME}/setup/default.rb"
    end

    let(:sample_setup) do
      "#{RGGEN_HOME}/sample/sample_setup.rb"
    end

    let(:sample_yaml) do
      "#{RGGEN_HOME}/sample/sample.yaml"
    end

    let(:sample_json) do
      "#{RGGEN_HOME}/sample/sample.json"
    end

    let(:sample_register_maps) do
      ["#{RGGEN_HOME}/sample/sample.xls", "#{RGGEN_HOME}/sample/sample.xlsx", "#{RGGEN_HOME}/sample/sample.csv"]
    end

    describe "ジェネレータのセットアップ" do
      before do
        allow(File).to receive(:binwrite)
      end

      context "--setupでセットアップファイルの指定が無い場合" do
        before do
          expect_any_instance_of(RgGen::Generator).to receive(:load).with(default_setup).and_call_original
        end

        before do
          expect(RgGen.builder).to receive(:enable).with(:global, [:data_width, :address_width, :unfold_sv_interface_port]).and_call_original
          expect(RgGen.builder).to receive(:enable).with(:register_block, [:name, :byte_size]).and_call_original
          expect(RgGen.builder).to receive(:enable).with(:register, [:offset_address, :name, :array, :type, :uniquness_validator]).and_call_original
          expect(RgGen.builder).to receive(:enable).with(:register, :type, [:indirect, :external]).and_call_original
          expect(RgGen.builder).to receive(:enable).with(:bit_field, [:bit_assignment, :name, :type, :initial_value, :reference]).and_call_original
          expect(RgGen.builder).to receive(:enable).with(:bit_field, :type, [:rw, :ro, :w0c, :w1c, :w0s, :w1s, :rwl, :rwe, :reserved]).and_call_original
          expect(RgGen.builder).to receive(:enable).with(:register_block, [:rtl_top, :clock_reset, :host_if]).and_call_original
          expect(RgGen.builder).to receive(:enable).with(:register_block, :host_if, [:apb, :axi4lite]).and_call_original
          expect(RgGen.builder).to receive(:enable).with(:register , :rtl_top).and_call_original
          expect(RgGen.builder).to receive(:enable).with(:bit_field, :rtl_top).and_call_original
          expect(RgGen.builder).to receive(:enable).with(:register_block, [:ral_package, :block_model, :constructor, :sub_model_creator, :default_map_creator]).and_call_original
          expect(RgGen.builder).to receive(:enable).with(:register, [:reg_model, :constructor, :field_model_creator, :indirect_index_configurator, :sub_block_model]).and_call_original
          expect(RgGen.builder).to receive(:enable).with(:bit_field, :field_model).and_call_original
          expect(RgGen.builder).to receive(:enable).with(:register_block, [:c_header_file, :address_struct]).and_call_original
        end

        it "デフォルトのセットアップが実行される" do
          expect {
            generator.run([sample_register_maps[0]])
          }.not_to raise_error
        end
      end

      context "--setupでセットアップファイルの指定がある場合" do
        context "指定したファイルが存在しない場合" do
          before do
            expect_any_instance_of(RgGen::Generator).to receive(:load).with(sample_setup).and_call_original
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
    end

    describe "コンフィグレーションの読み出し" do
      before do
        allow(File).to receive(:binwrite)
      end

      context "-c/--configurationでコンフィグレーションファイルの指定が無い場合" do
        it "デフォルト値でコンフィグレーションを生成する" do
          expect {
            generator.run([sample_register_maps[0]])
          }.not_to raise_error
          expect(factory_cache[:configuration][0]).to have_received(:create).with(nil)
        end
      end

      context "-c/--configurationでコンフィグレーションファイルの指定がある場合" do
        it "指定したファイルからコンフィグレーションを生成する" do
          expect {
            generator.run(["-c", sample_yaml, sample_register_maps[0]])
          }.not_to raise_error
          expect(factory_cache[:configuration][0]).to have_received(:create).with(sample_yaml)
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

      before do
        allow(File).to receive(:binwrite)
      end

      let(:configuration_cache) do
        []
      end

      it "オプション解析後の先頭の引数をレジスタマップとして読み出す" do
        expect {
          generator.run(['-c', sample_yaml, sample_register_maps[0], 'foo'])
        }.not_to raise_error
        expect(factory_cache[:register_map][0]).to have_received(:create).with(configuration_cache[0], sample_register_maps[0])
      end
    end

    describe "ファイルジェネレータの生成" do
      before do
        cache = configuration_cache
        factory_plugin[:configuration] = proc do |m, *args|
          cache << m.call(*args)
          cache.last
        end
      end

      before do
        cache = register_map_cache
        factory_plugin[:register_map] = proc do |m, *args|
          cache << m.call(*args)
          cache.last
        end
      end

      before do
        allow(File).to receive(:binwrite)
      end

      let(:configuration_cache) do
        []
      end

      let(:register_map_cache) do
        []
      end

      it "読み出したコンフィグレーション、レジスタマップからファイルジェネレータを生成する" do
        expect {
          generator.run([sample_register_maps[0]])
        }.not_to raise_error
        expect(factory_cache[:rtl][0]).to have_received(:create).with(configuration_cache[0], register_map_cache[0])
      end
    end

    describe "ファイルの書き出し" do
      let(:expected_rtl_code) do
        @expected_rtl_code
      end

      let(:expected_ral_code) do
        @expected_ral_code
      end

      let(:expected_c_header_code) do
        @expected_c_header_code
      end

      context "-o/--outputで出力ディレクトリの指定が無い場合" do
        it "カレントディレクトリにファイを書き出す" do
          expect {
            generator.run(['-c', sample_yaml, sample_register_maps[0]])
          }.to write_binary_files [
            ["./rtl/sample_0.sv"        , expected_rtl_code[0]     ],
            ["./rtl/sample_1.sv"        , expected_rtl_code[1]     ],
            ["./ral/sample_0_ral_pkg.sv", expected_ral_code[0]     ],
            ["./ral/sample_1_ral_pkg.sv", expected_ral_code[1]     ],
            ["./c_header/sample_0.h"    , expected_c_header_code[0]],
            ["./c_header/sample_1.h"    , expected_c_header_code[1]]
          ]
        end
      end

      context "-o/--outputで出力ディレクトリの指定がある場合" do
        it "指定されたディレクトリにファイを書き出す" do
          expect {
            generator.run(['-c', sample_yaml, '-o', '/foo/bar', sample_register_maps[0]])
          }.to write_binary_files [
            ["/foo/bar/rtl/sample_0.sv"        , expected_rtl_code[0]     ],
            ["/foo/bar/rtl/sample_1.sv"        , expected_rtl_code[1]     ],
            ["/foo/bar/ral/sample_0_ral_pkg.sv", expected_ral_code[0]     ],
            ["/foo/bar/ral/sample_1_ral_pkg.sv", expected_ral_code[1]     ],
            ["/foo/bar/c_header/sample_0.h"    , expected_c_header_code[0]],
            ["/foo/bar/c_header/sample_1.h"    , expected_c_header_code[1]]
          ]
        end
      end

      context "--load-onlyが指定されている場合" do
        before do
          expect(File).not_to receive(:binwrite)
        end

        it "ファイルの読み出しのみ行う" do
          generator.run(['--load-only', '-c', sample_yaml, sample_register_maps[0]])
          expect(factory_cache[:configuration][0]).to have_received(:create)
          expect(factory_cache[:register_map ][0]).to have_received(:create)
        end
      end

      context "--disableで書き出し無効指定がある場合" do
        it "無効になっていない種類のファイルを書き出す" do
          expect {
            generator.run(['-c', sample_yaml, '--disable', 'rtl,foo', sample_register_maps[0]])
          }.to write_binary_files [
            ["./ral/sample_0_ral_pkg.sv", expected_ral_code[0]     ],
            ["./ral/sample_1_ral_pkg.sv", expected_ral_code[1]     ],
            ["./c_header/sample_0.h"    , expected_c_header_code[0]],
            ["./c_header/sample_1.h"    , expected_c_header_code[1]]
          ]
          clear_enabled_items

          expect {
            generator.run(['-c', sample_yaml, '--disable', 'rtl,ral,c_header', sample_register_maps[0]])
          }.not_to write_binary_files
          clear_enabled_items
        end
      end
    end

    describe "例外の捕捉" do
      context " OptionParser::ParseErrorが発生した場合" do
        it "標準エラー出力にメッセージを出力し、終了する" do
          expect {
            generator.run(['--foo'])
          }.to raise_error(SystemExit).and output("[InvalidOption] invalid option: --foo\n").to_stderr
        end
      end

      context "LoadErrorが発生した場合" do
        before do
          allow(File).to receive(:exist?).and_call_original
          allow(File).to receive(:exist?).with(sample_setup           ).and_return(false)
          allow(File).to receive(:exist?).with(sample_yaml            ).and_return(false)
          allow(File).to receive(:exist?).with(sample_register_maps[0]).and_return(false)
        end

        it "標準エラー出力にメッセージを出力し、終了する" do
          expect {
            generator.run(["--setup", sample_setup, sample_register_maps[1]])
          }.to raise_error(SystemExit).and output("[LoadError] cannot load such file -- #{sample_setup}\n").to_stderr

          expect {
            generator.run(['-c', sample_yaml, sample_register_maps[0]])
          }.to raise_error(SystemExit).and output("[LoadError] cannot load such file -- #{sample_yaml}\n").to_stderr

          expect {
            generator.run([])
          }.to raise_error(SystemExit).and output("[LoadError] no register map is specified\n").to_stderr

          expect {
            generator.run([sample_register_maps[0]])
          }.to raise_error(SystemExit).and output("[LoadError] cannot load such file -- #{sample_register_maps[0]}\n").to_stderr
        end
      end

      context "ConfiguratinErrorが発生した場合" do
        before do
          allow_any_instance_of(Configuration::Item).to receive(:build) do
            raise RgGen::ConfigurationError, "bad configuration"
          end
        end

        it "標準エラー出力にメッセージを出力し、終了する" do
          expect {
            generator.run(['-c', sample_yaml, sample_register_maps[0]])
          }.to raise_error(SystemExit).and output("[ConfigurationError] bad configuration\n").to_stderr
        end
      end

      context "RegisterMapErrorが発生した場合" do
        before do
          allow_any_instance_of(Configuration::Item).to receive(:build) do
            raise RgGen::RegisterMapError.new("bad register map", position)
          end
        end

        let(:position) do
          RgGen::RegisterMap::GenericMap::Cell::Position.new(sample_register_maps[0], "block_0", 0, 0)
        end

        it "標準エラー出力にメッセージを出力し、終了する" do
          expect {
            generator.run(['-c', sample_yaml, sample_register_maps[0]])
          }.to raise_error(SystemExit).and output("[RegisterMapError] bad register map -- #{position}\n").to_stderr
        end
      end
    end
  end
end
