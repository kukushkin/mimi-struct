# frozen_string_literal: true

require 'spec_helper'

RSpec.describe "Mimi::Struct DSL :group" do
  let(:subclass) do
    Class.new(Mimi::Struct) do
      attribute :a
      group optional: true do
        attribute :b
      end
    end
  end

  subject { subclass }

  it "successfully maps the object with correct attributes" do
    expect { subject.new(a: 1, b: 2) }.to_not raise_error
  end

  it "applies group parameters to attributes" do
    expect { subject.new(a: 1) }.to_not raise_error
    object = subject.new(a: 1)
    expect(object).to_not respond_to(:b)
    expect { subject.new(a: 1, b: 2) }.to_not raise_error
    object = subject.new(a: 1, b: 2)
    expect(object).to respond_to(:b)
    expect(object.b).to eq 2
  end
end
