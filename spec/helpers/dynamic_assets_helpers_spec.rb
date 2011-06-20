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
              DynamicAssets::StylesheetReference.new.tap { |r| r.stub(:name => "a", :signature => 123) },
              DynamicAssets::StylesheetReference.new.tap { |r| r.stub(:name => "b", :signature => 456) },
              DynamicAssets::StylesheetReference.new.tap { |r| r.stub(:name => "c", :signature => 789) }
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

          it "is three tags with hrefs derived from the asset name and signature" do
            should contain_string 'href="/assets/stylesheets/v/123/a.css"'
            should contain_string 'href="/assets/stylesheets/v/456/b.css"'
            should contain_string 'href="/assets/stylesheets/v/789/c.css"'
          end

          context "when the arguments also include :signature => false" do
            before { args << { :signature => false } }
            it "omits the signature from the URL" do
              should contain_string 'href="/assets/stylesheets/a.css"'
            end
          end

          context "when the arguments also include a :token" do
            before { args << { :token => "something" } }
            it "includes the token in the URL" do
              should contain_string 'href="/assets-something/stylesheets/v/123/a.css"'
            end
          end

          context "when the arguments also include a :host" do
            before { args << { :host => "topsy.foo" } }
            it "adds the host to the URL" do
              should contain_string 'href="http://topsy.foo/assets/stylesheets/v/123/a.css"'
            end
          end
        end

        context "when config.asset_host is set to a.example.com (with no protocol)" do
          before { helper.config.stub(:asset_host).and_return "a.example.com" }

          it "is three tags with hrefs whose host is a.example.com" do
            should contain_string 'href="http://a.example.com/assets/stylesheets/v/123/a.css"'
            should contain_string 'href="http://a.example.com/assets/stylesheets/v/456/b.css"'
            should contain_string 'href="http://a.example.com/assets/stylesheets/v/789/c.css"'
          end

          context "when the arguments also include a :host" do
            before { args << { :host => "topsy.foo" } }
            it "includes the host in the URL, instead of the asset host" do
              should contain_string 'href="http://topsy.foo/assets/stylesheets/v/123/a.css"'
            end
          end
        end

        context "when config.asset_host is set to http://a.example.com" do
          before { helper.config.stub(:asset_host).and_return "http://a.example.com" }

          it "is three tags with hrefs whose host is a.example.com" do
            should contain_string 'href="http://a.example.com/assets/stylesheets/v/123/a.css"'
            should contain_string 'href="http://a.example.com/assets/stylesheets/v/456/b.css"'
            should contain_string 'href="http://a.example.com/assets/stylesheets/v/789/c.css"'
          end

          context "when the arguments also include :signature => false" do
            before { args << { :signature => false } }
            it "omits the signature from the URL" do
              should contain_string 'href="http://a.example.com/assets/stylesheets/a.css"'
            end
          end

          context "when the arguments also include a :token" do
            before { args << { :token => "something" } }
            it "includes the token in the URL" do
              should contain_string 'href="http://a.example.com/assets-something/stylesheets/v/123/a.css"'
            end
          end

          context "when the arguments also include a :host" do
            before { args << { :host => "topsy.foo" } }
            it "includes the host in the URL, instead of the asset host" do
              should contain_string 'href="http://topsy.foo/assets/stylesheets/v/123/a.css"'
            end
          end
        end

        context "when config.asset_host is set to a%d.example.com" do
          before { helper.config.stub(:asset_host).and_return "http://a%d.example.com" }

          it "is three tags with hrefs whose host is a[0-3].example.com" do
            should =~ /href="http:\/\/a[0-3].example.com\/assets\/stylesheets\/v\/123\/a.css"/
            should =~ /href="http:\/\/a[0-3].example.com\/assets\/stylesheets\/v\/456\/b.css"/
            should =~ /href="http:\/\/a[0-3].example.com\/assets\/stylesheets\/v\/789\/c.css"/
          end

          context "when the arguments also include :signature => false" do
            before { args << { :signature => false } }
            it "omits the signature from the URL" do
              should =~ /href="http:\/\/a[0-3].example.com\/assets\/stylesheets\/a.css"/
            end
          end

          context "when the arguments also include a :token" do
            before { args << { :token => "something" } }
            it "includes the token in the URL" do
              should =~ /href="http:\/\/a[0-3].example.com\/assets-something\/stylesheets\/v\/123\/a.css"/
            end
          end

          context "when the arguments also include a :host" do
            before { args << { :host => "topsy.foo" } }
            it "includes the host in the URL, instead of the asset host" do
              should contain_string 'href="http://topsy.foo/assets/stylesheets/v/123/a.css"'
            end
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
              DynamicAssets::JavascriptReference.new.tap { |r| r.stub(:name => "a", :signature => 123) },
              DynamicAssets::JavascriptReference.new.tap { |r| r.stub(:name => "b", :signature => 456) },
              DynamicAssets::JavascriptReference.new.tap { |r| r.stub(:name => "c", :signature => 789) }
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

          it "is three tags with srcs derived from the asset name and signature" do
            should contain_string 'src="/assets/javascripts/v/123/a.js"'
            should contain_string 'src="/assets/javascripts/v/456/b.js"'
            should contain_string 'src="/assets/javascripts/v/789/c.js"'
          end

          context "when the arguments also include a :token" do
            before { args << { :token => "something" } }
            it "includes the token in the URL" do
              should contain_string 'src="/assets-something/javascripts/v/123/a.js"'
            end
          end
        end

        context "when config.asset_host is set to a.example.com" do
          before { helper.config.stub(:asset_host).and_return "http://a.example.com" }

          it "is three tags with srcs whose host is a.example.com" do
            should contain_string 'src="http://a.example.com/assets/javascripts/v/123/a.js"'
            should contain_string 'src="http://a.example.com/assets/javascripts/v/456/b.js"'
            should contain_string 'src="http://a.example.com/assets/javascripts/v/789/c.js"'
          end

          context "when the arguments also include a :token" do
            before { args << { :token => "something" } }
            it "includes the token in the URL" do
              should contain_string 'src="http://a.example.com/assets-something/javascripts/v/123/a.js"'
            end
          end
        end

        context "when config.asset_host is set to a%d.example.com" do
          before { helper.config.stub(:asset_host).and_return "http://a%d.example.com" }

          it "is three tags with srcs whose host is a[0-3].example.com" do
            should =~ /src="http:\/\/a[0-3].example.com\/assets\/javascripts\/v\/123\/a.js"/
            should =~ /src="http:\/\/a[0-3].example.com\/assets\/javascripts\/v\/456\/b.js"/
            should =~ /src="http:\/\/a[0-3].example.com\/assets\/javascripts\/v\/789\/c.js"/
          end

          context "when the arguments also include a :token" do
            before { args << { :token => "something" } }
            it "includes the token in the URL" do
              should =~ /src="http:\/\/a[0-3].example.com\/assets-something\/javascripts\/v\/123\/a.js"/
            end
          end
        end
      end
    end
  end

end
