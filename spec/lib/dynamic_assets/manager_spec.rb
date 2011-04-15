require 'spec_helper'

describe DynamicAssets::Manager do

  it "contains config methods, like a singleton" do
    expect { DynamicAssets::Manager.combine_asset_groups? }.not_to raise_error
  end

end
