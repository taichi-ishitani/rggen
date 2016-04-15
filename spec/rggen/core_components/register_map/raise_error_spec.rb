require_relative  'spec_helper'

module RgGen::RegisterMap
  describe RaiseError do
    let(:object) do
      Class.new {
        include RaiseError
        attr_writer :position
      }.new
    end

    let(:cell) do
      create_cell(:foo)
    end

    let(:position) do
      cell.position
    end

    let(:message) do
      "some register map error"
    end

    describe "#error" do
      context "エラーメッセージのみ与えられた場合" do
        before do
          object.position = cell.position
        end

        it "入力されたメッセージと自身が持つ位置情報で、RgGen::RegisterMapErrorを発生させる" do
          expect {
            object.send(:error, message)
          }.to raise_register_map_error(message, cell.position)
        end
      end

      context "エラーメッセージと位置情報が与えられた場合" do
        before do
          object.position = cell.position
        end

        it "入力されたメッセージと位置情報で、RgGen::RegisterMapErrorを発生させる" do
          expect {
            object.send(:error, message, position)
          }.to raise_register_map_error(message, position)
        end
      end

      context "エラーメッセージと入力セルが与えられた場合" do
        before do
          object.position = position
        end

        it "入力されたメッセージと入力セルが持つ位置情報で、RgGen::RegisterMapErrorを発生させる" do
          expect {
            object.send(:error, message, cell)
          }.to raise_register_map_error(message, position)
        end
      end
    end
  end
end
