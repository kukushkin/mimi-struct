# frozen_string_literal: true

require 'spec_helper'

RSpec.describe "Mimi::Struct DSL :default" do
  let(:subclass) do
    Class.new(Mimi::Struct) do
      attribute :a, default: -> { 1 }
    end
  end

  subject { subclass }

  it "successfully maps the object with correct attributes" do
    expect { subject.new(b: 2) }.to_not raise_error
  end

  it "allows the source attribute to be omitted" do
    expect { subject.new() }.to_not raise_error
    expect { subject.new({}) }.to_not raise_error
  end

  it "sets the attribute to default value" do
    object = subject.new()
    expect(object).to respond_to(:a)
    expect(object.a).to eq 1
  end

  context "with a literal default value" do
    let(:subclass) do
      Class.new(Mimi::Struct) do
        attribute :a, default: 1
      end
    end

    it "successfully maps the object with correct attributes" do
      expect { subject.new(b: 2) }.to_not raise_error
    end

    it "allows the source attribute to be omitted" do
      expect { subject.new() }.to_not raise_error
      expect { subject.new({}) }.to_not raise_error
    end

    it "sets the attribute to default value" do
      object = subject.new()
      expect(object).to respond_to(:a)
      expect(object.a).to eq 1
    end
  end # with a literal default value
end
