# frozen_string_literal: true

require 'spec_helper'

RSpec.describe "Mimi::Struct DSL :if" do
  let(:subclass) do
    Class.new(Mimi::Struct) do
      attribute :a
      attribute :b, if: -> (o) { o.a == 1 }
    end
  end

  subject { subclass }

  it "successfully maps the object with correct attributes" do
    expect { subject.new(a: 1, b: 2) }.to_not raise_error
  end

  it "maps the attribute if the :if block evaluates to true" do
    expect { subject.new(a: 1, b: 2) }.to_not raise_error
    object = subject.new(a: 1, b: 2)
    expect(object).to respond_to(:b)
    expect(object.b).to eq 2
  end

  it "does NOT map the attribute if the :if block evaluates to false" do
    expect { subject.new(a: 2) }.to_not raise_error
    object = subject.new(a: 2)
    expect(object).to_not respond_to(:b)
  end
end
