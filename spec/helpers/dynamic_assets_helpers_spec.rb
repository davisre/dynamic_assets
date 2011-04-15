require 'spec_helper'

describe DynamicAssetsHelpers do

  describe "#stylesheet_asset_tag" do
    subject { helper.stylesheet_asset_tag group_key }

    context "when the DynamicAssets::Manager says the given group key is associated with 3 stylesheets" do
      let(:group_key) { :base }

      before do
        DynamicAssets::Manager.stub(:asset_references_for_group_key).with(:stylesheets, group_key).
          and_return [
            double(DynamicAssets::Reference, :name => "a", :mtime => 123),
            double(DynamicAssets::Reference, :name => "b", :mtime => 456),
            double(DynamicAssets::Reference, :name => "c", :mtime => 789)
          ]
      end

      it "is three link tags" do
        subject.scan('<link ').length.should == 3
      end

      it 'is three tags with type="text/css"' do
        subject.scan('type="text/css"').length.should == 3
      end

      it 'is three tags with rel"stylesheet"' do
        subject.scan('rel="stylesheet"').length.should == 3
      end

      it 'is three tags with media="screen"' do
        subject.scan('media="screen"').length.should == 3
      end

      context "when config.asset_host is nil" do
        before { helper.config.asset_host.should be_nil }

        it "is three tags with hrefs derived from the asset name and mtime" do
          should contain_string 'href="/assets/stylesheets/a.css?123"'
          should contain_string 'href="/assets/stylesheets/b.css?456"'
          should contain_string 'href="/assets/stylesheets/c.css?789"'
        end
      end

      context "when config.asset_host is set to a.example.com" do
        before { helper.config.stub(:asset_host).and_return "http://a.example.com" }

        it "is three tags with hrefs whose host is a.example.com" do
          should contain_string 'href="http://a.example.com/assets/stylesheets/a.css?123"'
          should contain_string 'href="http://a.example.com/assets/stylesheets/b.css?456"'
          should contain_string 'href="http://a.example.com/assets/stylesheets/c.css?789"'
        end
      end

      context "when config.asset_host is set to a%d.example.com" do
        before { helper.config.stub(:asset_host).and_return "http://a%d.example.com" }

        it "is three tags with hrefs whose host is a[0-3].example.com" do
          should =~ /href="http:\/\/a[0-3].example.com\/assets\/stylesheets\/a.css\?123"/
          should =~ /href="http:\/\/a[0-3].example.com\/assets\/stylesheets\/b.css\?456"/
          should =~ /href="http:\/\/a[0-3].example.com\/assets\/stylesheets\/c.css\?789"/
        end
      end
    end

  end

end
