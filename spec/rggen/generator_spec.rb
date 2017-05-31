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

    describe "RgGenホームディレクトリの表示" do
      let(:home) do
        "#{RgGen::RGGEN_HOME}\n"
      end

      it "RgGenのホームディレクトリを表示し、そのまま終了する" do
        expect {
          generator.run(['--show-home'])
        }.to raise_error(SystemExit).and output(home).to_stdout
      end
    end

    describe "バージョンの出力" do
      let(:version) do
        "rggen #{RgGen::VERSION}\n"
      end

      it "バージョンを出力し、そのまま終了する" do
        expect {
          generator.run(['-v'])
        }.to raise_error(SystemExit).and output(version).to_stdout
        expect {
          generator.run(['--version'])
        }.to raise_error(SystemExit).and output(version).to_stdout
      end
    end

    describe "ヘルプの表示" do
      let(:help) do
        <<HELP
Usage: rggen [options] REGISTER_MAP
        --setup FILE                 Specify a setup file to set up RgGen tool(default: #{default_setup})
    -c, --configuration FILE         Specify a configuration file for generated source code
    -o, --output DIR                 Specify output directory(default: .)
        --except [TYPE1,TYPE2,...]   Disable the given output file type(s)
        --show-home                  Display the path of RgGen tool home directory
    -v, --version                    Display the version
    -h, --help                       Display this message
HELP
      end

      it "ヘルプを表示し、そのまま終了する" do
        expect {
          generator.run(['-h'])
        }.to raise_error(SystemExit).and output(help).to_stdout
        expect {
          generator.run(['--help'])
        }.to raise_error(SystemExit).and output(help).to_stdout
      end
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
          expect(RgGen.builder).to receive(:enable).with(:global, [:data_width, :address_width]).and_call_original
          expect(RgGen.builder).to receive(:enable).with(:register_block, [:name, :byte_size]).and_call_original
          expect(RgGen.builder).to receive(:enable).with(:register, [:offset_address, :name, :array, :type, :uniquness_validator]).and_call_original
          expect(RgGen.builder).to receive(:enable).with(:register, :type, [:indirect, :external]).and_call_original
          expect(RgGen.builder).to receive(:enable).with(:bit_field, [:bit_assignment, :name, :type, :initial_value, :reference]).and_call_original
          expect(RgGen.builder).to receive(:enable).with(:bit_field, :type, [:rw, :ro, :w0c, :w1c, :w0s, :w1s, :rwl, :rwe, :reserved]).and_call_original
          expect(RgGen.builder).to receive(:enable).with(:register_block, [:rtl_top, :clock_reset, :host_if, :irq_controller]).and_call_original
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

      context "環境変数 RGGEN_DEFAULT_SETUP_FILE が設定されている場合" do
        before do
          allow(ENV).to receive(:[]).and_call_original
          allow(ENV).to receive(:[]).with('RGGEN_DEFAULT_SETUP_FILE').and_return(sample_setup)
        end

        after do
          clear_dummy_list_items(:type   , [:foo])
          clear_dummy_list_items(:host_if, [:bar])
        end

        specify "指定されたファイルをデフォルトのセットアップファイルとする" do
          expect_any_instance_of(RgGen::Generator).to receive(:load).with(sample_setup).and_call_original
          expect {
            generator.run([sample_register_maps[1]])
          }.not_to raise_error
          clear_enabled_items

          expect_any_instance_of(RgGen::Generator).to receive(:load).with(default_setup).and_call_original
          expect {
            generator.run(["--setup", default_setup, sample_register_maps[0]])
          }.not_to raise_error
        end

        specify "ヘルプメッセージを変更される" do
          help  = <<HELP
        --setup FILE                 Specify a setup file to set up RgGen tool(default: #{sample_setup})
HELP
          expect {
            generator.run(['-h'])
          }.to raise_error(SystemExit).and output(/#{Regexp.escape(help.chomp)}/).to_stdout
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
          clear_enabled_items

          expect {
            generator.run(["--configuration", sample_json, sample_register_maps[0]])
          }.not_to raise_error
          expect(factory_cache[:configuration][1]).to have_received(:create).with(sample_json)
        end
      end

      context "環境変数 RGGEN_DEFAULT_CONFIGURATION_FILE が設定されている場合" do
        before do
          allow(ENV).to receive(:[]).and_call_original
          allow(ENV).to receive(:[]).with('RGGEN_DEFAULT_CONFIGURATION_FILE').and_return(sample_json)
        end

        specify "指定されたファイルをデフォルトのコンフィグレーションファイルとする" do
          expect {
            generator.run([sample_register_maps[0]])
          }.not_to raise_error
          expect(factory_cache[:configuration][0]).to have_received(:create).with(sample_json)

          expect {
            generator.run(["-c", sample_yaml, sample_register_maps[0]])
          }.not_to raise_error
          expect(factory_cache[:configuration][1]).to have_received(:create).with(sample_yaml)
          clear_enabled_items
        end

        specify "ヘルプメッセージが変更される" do
          help  = <<HELP
-c, --configuration FILE         Specify a configuration file for generated source code(default: #{sample_json})
HELP
          expect {
            generator.run(['-h'])
          }.to raise_error(SystemExit).and output(/#{Regexp.escape(help.chomp)}/).to_stdout
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
          clear_enabled_items

          expect {
            generator.run(['-c', sample_yaml, '--output', '../baz', sample_register_maps[0]])
          }.to write_binary_files [
            ["../baz/rtl/sample_0.sv"        , expected_rtl_code[0]     ],
            ["../baz/rtl/sample_1.sv"        , expected_rtl_code[1]     ],
            ["../baz/ral/sample_0_ral_pkg.sv", expected_ral_code[0]     ],
            ["../baz/ral/sample_1_ral_pkg.sv", expected_ral_code[1]     ],
            ["../baz/c_header/sample_0.h"    , expected_c_header_code[0]],
            ["../baz/c_header/sample_1.h"    , expected_c_header_code[1]]
          ]
        end
      end

      context "--exceptで書き出し除外指定がある場合" do
        it "除外されていない種類のファイルを書き出す" do
          expect {
            generator.run(['-c', sample_yaml, '--except', 'rtl', sample_register_maps[0]])
          }.to write_binary_files [
            ["./ral/sample_0_ral_pkg.sv", expected_ral_code[0]     ],
            ["./ral/sample_1_ral_pkg.sv", expected_ral_code[1]     ],
            ["./c_header/sample_0.h"    , expected_c_header_code[0]],
            ["./c_header/sample_1.h"    , expected_c_header_code[1]]
          ]
          clear_enabled_items

          expect {
            generator.run(['-c', sample_yaml, '--except', 'ral', '--except', 'rtl,foo', '--except', 'c_header', sample_register_maps[0]])
          }.not_to write_binary_files
          clear_enabled_items
        end
      end
    end
  end
end
