require 'spec_helper'

describe FulltextSearchable do
  it "should be valid" do
    FulltextSearchable.should be_a(Module)
  end

  describe "config" do
    it "warns deprecation of async option" do
      expect(ActiveSupport::Deprecation).to receive(:warn).
        with('FulltextSearchable::Engine.config.async no longer exists and has no effect.')
      FulltextSearchable::Engine.config.async = true
    end
  end
end
