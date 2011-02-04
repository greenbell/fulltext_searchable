require 'spec_helper'

describe FulltextSearchable do
  it "should be valid" do
    FulltextSearchable.should be_a(Module)
  end

  it "should raise NotEnabled on invalid fulltext_referencd" do
    lambda do
      class Errornous < ActiveRecord::Base
        fulltext_referenced :name
      end
    end.should raise_error FulltextSearchable::NotEnabled
  end
end
