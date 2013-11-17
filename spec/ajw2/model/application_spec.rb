require "spec_helper"

module Ajw2::Model
  describe Application do
    describe "#initialize" do
      subject { Ajw2::Model::Application.new("sample") }
      its(:name) { should be_instance_of String }
    end
  end
end
