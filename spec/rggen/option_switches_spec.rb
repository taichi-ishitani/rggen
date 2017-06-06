require_relative '../spec_helper'

module RgGen
  describe 'option switches' do
    let(:options) do
      Options.new
    end

    describe 'setup' do
      let(:setup) do
        'foo/bar.rb'
      end

      it "オプションで指定したファイルのパスを返す" do
        aggregate_failures do
          expect {
            options.parse(['--setup', setup])
          }.not_to raise_error
          expect(options[:setup]).to eq setup
        end
      end

      describe "デフォルト値" do
        context "環境変数 RGGEN_DEFAULT_SETUP_FILE が定義されている場合" do
          before do
            allow(ENV).to receive(:[]).and_call_original
            allow(ENV).to receive(:[]).with('RGGEN_DEFAULT_SETUP_FILE').and_return(setup)
          end

          it "当該環境変数で指定されたファイルのパスを返す" do
            expect(options[:setup]).to eq setup
          end
        end

        context "環境変数 RGGEN_DEFAULT_SETUP_FILE が定義されていない場合" do
          let(:default_setup) do
            "#{RgGen::RGGEN_HOME}/setup/default.rb"
          end

          it "当該環境変数で指定されたファイルパスを返す" do
            expect(options[:setup]).to eq default_setup
          end
        end
      end
    end

    describe 'configuration' do
      let(:configuration_files) do
        ['config.yaml', 'config.json']
      end

      it "指定したコンフィグレーションファイルのパスを返す" do
        aggregate_failures do
          expect { options.parse(['-c', configuration_files[0]]) }.not_to raise_error
          expect(options[:configuration]).to eq configuration_files[0]
        end

        aggregate_failures do
          expect { options.parse(['--configuration', configuration_files[1]]) }.not_to raise_error
          expect(options[:configuration]).to eq configuration_files[1]
        end
      end

      describe "デフォルト値" do
        context "環境変数 RGGEN_DEFAULT_CONFIGURATION_FILE が定義されている場合" do
          before do
            allow(ENV).to receive(:[]).and_call_original
            allow(ENV).to receive(:[]).with('RGGEN_DEFAULT_CONFIGURATION_FILE').and_return(configuration_files[0])
          end

          it "当該環境変数で指定したファイルパスを返す" do
            expect(options[:configuration]).to eq configuration_files[0]
          end
        end

        context "環境変数 RGGEN_DEFAULT_CONFIGURATION_FILE が定義されていない場合" do
          it "nilを返す" do
            expect(options[:configuration]).to be_nil
          end
        end
      end
    end

    describe 'output' do
      let(:output_directories) do
        ['foo', 'bar/baz']
      end

      it "指定した出力ディレクトリを返す" do
        aggregate_failures do
          expect {
            options.parse(['-o', output_directories[0]])
          }.not_to raise_error
          expect(options[:output]).to eq output_directories[0]
        end

        aggregate_failures do
          expect {
            options.parse(['--output', output_directories[1]])
          }.not_to raise_error
          expect(options[:output]).to eq output_directories[1]
        end
      end

      describe "デフォルト値" do
        it ".を返す" do
          expect(options[:output]).to eq "."
        end
      end
    end

    describe 'load_only' do
      context "--load-only が指定された場合" do
        it "真を返す" do
          aggregate_failures do
            expect {
              options.parse(['--load-only'])
            }.not_to raise_error
            expect(options[:load_only]).to be
          end
        end
      end

      describe "デフォルト値" do
        it "偽を返す" do
          expect(options[:load_only]).not_to be
        end
      end
    end

    describe 'disable' do
      it "指定した無効タイプリストを返す" do
        aggregate_failures do
          expect {
            options.parse(['--disable', 'foo', '--disable', 'bar,baz'])
          }.not_to raise_error
          expect(options[:disable]).to be_instance_of(Array).and match [:foo, :bar, :baz]
        end
      end

      describe "デフォルト値" do
        it "空の配列を返す" do
          expect(options[:disable]).to be_instance_of(Array).and be_empty
        end
      end
    end

    describe 'show_home' do
      it "インストールディレクトリを表示して、正常終了する" do
        expect {
          options.parse(['--show-home'])
        }.to exit_with_code(0).and output(RgGen::RGGEN_HOME + "\n").to_stdout
      end
    end

    describe 'help' do
      let(:message) do
        <<HELP
Usage: rggen [options] REGISTER_MAP
        --setup FILE                 Specify a setup file to set up RgGen tool(default: #{RgGen::RGGEN_HOME}/setup/default.rb)
    -c, --configuration FILE         Specify a configuration file for generated source code
    -o, --output DIR                 Specify output directory(default: .)
        --load-only                  Load input files only if specified
        --disable TYPE1[,TYPE2,...]  Disable the given output file type(s)(default: [])
        --show-home                  Display the path of RgGen tool home directory
    -v, --version                    Display the version
    -h, --help                       Display this message
HELP
      end

      it "ヘルプメッセージを表示して、正常終了する" do
        expect {
          options.parse(['-h'])
        }.to exit_with_code(0).and output(message).to_stdout
        expect {
          options.parse(['--help'])
        }.to exit_with_code(0).and output(message).to_stdout
      end

      context "RGGEN_DEFAULT_SETUP_FILE/RGGEN_DEFAULT_CONFIGURATION_FILEの設定がある場合" do
        before do
          allow(ENV).to receive(:[]).and_call_original
          allow(ENV).to receive(:[]).with('RGGEN_DEFAULT_SETUP_FILE').and_return('foo/bar.rb')
          allow(ENV).to receive(:[]).with('RGGEN_DEFAULT_CONFIGURATION_FILE').and_return('baz/qux.yaml')
        end

        let(:message_with_default_environment_variables) do
          <<HELP
Usage: rggen [options] REGISTER_MAP
        --setup FILE                 Specify a setup file to set up RgGen tool(default: foo/bar.rb)
    -c, --configuration FILE         Specify a configuration file for generated source code(default: baz/qux.yaml)
    -o, --output DIR                 Specify output directory(default: .)
        --load-only                  Load input files only if specified
        --disable TYPE1[,TYPE2,...]  Disable the given output file type(s)(default: [])
        --show-home                  Display the path of RgGen tool home directory
    -v, --version                    Display the version
    -h, --help                       Display this message
HELP
        end

        it "デフォルト値の変更を反映したヘルプメッセージを表示する" do
          expect {
            options.parse(['-h'])
          }.to exit_with_code(0).and output(message_with_default_environment_variables).to_stdout
          expect {
            options.parse(['--help'])
          }.to exit_with_code(0).and output(message_with_default_environment_variables).to_stdout
        end
      end
    end

    describe 'version' do
      it "バージョンを表示して、正常終了する" do
        expect {
          options.parse(['-v'])
        }.to exit_with_code(0).and output("rggen #{RgGen::VERSION}\n").to_stdout
        expect {
          options.parse(['--version'])
        }.to exit_with_code(0).and output("rggen #{RgGen::VERSION}\n").to_stdout
      end
    end
  end
end

