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
            expect(configuration_factory).to receive(:create).with('foo.yaml').and_call_original
            expect(configuration_factory).to receive(:create).with('foo.json').and_call_original
          end

          it "指定したファイルからコンフィグレーションを生成する" do
            expect {
              generator.run(["-c", "foo.yaml"])
            }.to raise_error Errno::ENOENT
            expect {
              generator.run(["--configuration", "foo.json"])
            }.to raise_error Errno::ENOENT
          end
        end
      end
    end
  end
end
