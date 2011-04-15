require 'spec_helper'

describe DynamicAssetsHelpers do

  describe "#stylesheet_asset_tag" do
    subject { helper.stylesheet_asset_tag *args }

    context "when called with no arguments" do
      let(:args) { [] }

      it "fails with an ArgumentError" do
        expect { subject }.to raise_error ArgumentError
      end
    end

    context "when called with a group_key" do
      let(:args)      { [group_key] }
      let(:group_key) { :base }

      context "when the DynamicAssets::Manager says the given group key is associated with 3 stylesheets" do

        before do
          DynamicAssets::Manager.stub(:asset_references_for_group_key).with(:stylesheets, group_key).
            and_return [
              DynamicAssets::StylesheetReference.new.tap { |r| r.stub(:name => "a", :mtime => 123) },
              DynamicAssets::StylesheetReference.new.tap { |r| r.stub(:name => "b", :mtime => 456) },
              DynamicAssets::StylesheetReference.new.tap { |r| r.stub(:name => "c", :mtime => 789) }
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

        context "when the arguments also include HTML attributes" do
          before { args << { :media => "print", :id => "foo" } }

          it "is three links, each of which has the given attributes" do
            subject.scan('media="print"').length.should == 3
            subject.scan('id="foo"').length.should == 3
          end
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

  describe "#javascript_asset_tag" do
    subject { helper.javascript_asset_tag *args }

    context "when called with no arguments" do
      let(:args) { [] }

      it "fails with an ArgumentError" do
        expect { subject }.to raise_error ArgumentError
      end
    end

    context "when called with a group_key" do
      let(:args)      { [group_key] }
      let(:group_key) { :base }

      context "when the DynamicAssets::Manager says the given group key is associated with 3 scripts" do

        before do
          DynamicAssets::Manager.stub(:asset_references_for_group_key).with(:javascripts, group_key).
            and_return [
              DynamicAssets::JavascriptReference.new.tap { |r| r.stub(:name => "a", :mtime => 123) },
              DynamicAssets::JavascriptReference.new.tap { |r| r.stub(:name => "b", :mtime => 456) },
              DynamicAssets::JavascriptReference.new.tap { |r| r.stub(:name => "c", :mtime => 789) }
            ]
        end

        it "is three script tags" do
          subject.scan('<script ').length.should == 3
        end

        it 'is three tags with type="text/javascript"' do
          subject.scan('type="text/javascript"').length.should == 3
        end

        context "when the arguments also include HTML attributes" do
          before { args << { :id => "foo" } }

          it "is three links, each of which has the given attributes" do
            subject.scan('id="foo"').length.should == 3
          end
        end

        context "when config.asset_host is nil" do
          before { helper.config.asset_host.should be_nil }

          it "is three tags with srcs derived from the asset name and mtime" do
            should contain_string 'src="/assets/javascripts/a.js?123"'
            should contain_string 'src="/assets/javascripts/b.js?456"'
            should contain_string 'src="/assets/javascripts/c.js?789"'
          end
        end

        context "when config.asset_host is set to a.example.com" do
          before { helper.config.stub(:asset_host).and_return "http://a.example.com" }

          it "is three tags with srcs whose host is a.example.com" do
            should contain_string 'src="http://a.example.com/assets/javascripts/a.js?123"'
            should contain_string 'src="http://a.example.com/assets/javascripts/b.js?456"'
            should contain_string 'src="http://a.example.com/assets/javascripts/c.js?789"'
          end
        end

        context "when config.asset_host is set to a%d.example.com" do
          before { helper.config.stub(:asset_host).and_return "http://a%d.example.com" }

          it "is three tags with srcs whose host is a[0-3].example.com" do
            should =~ /src="http:\/\/a[0-3].example.com\/assets\/javascripts\/a.js\?123"/
            should =~ /src="http:\/\/a[0-3].example.com\/assets\/javascripts\/b.js\?456"/
            should =~ /src="http:\/\/a[0-3].example.com\/assets\/javascripts\/c.js\?789"/
          end
        end
      end
    end
  end

end
