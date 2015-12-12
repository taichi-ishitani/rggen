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
    end
  end
end
