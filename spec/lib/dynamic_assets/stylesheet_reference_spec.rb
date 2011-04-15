require 'spec_helper'

module DynamicAssets
  describe StylesheetReference do

    describe "#content" do
      subject         { reference.content }
      let(:reference) { StylesheetReference.new :name => "thing" }

      context "when a css file with the given reference name exists" do
        before do
          reference.stub(:path_for_member_name).with("thing").and_return "/foo/thing.css"
          reference.stub(:raw_content_exists?).with("/foo/thing.css").and_return true
          reference.stub(:get_raw_content).with("/foo/thing.css").and_return raw_content
        end

        context "and the file is blank" do
          let(:raw_content) { "" }
          it { should be_blank }
        end

        context "and the file contains styles" do
          let(:raw_content) { "div.foo { color: #FFF }" }

          context "and the Manager is not configured to minify" do
            before { Manager.stub :minify? => false }

            it "is the raw content" do
              subject.should == raw_content
            end

            it "does not call its own #minify method" do
              reference.should_not_receive :minify
              subject
            end
          end

          context "and the Manager is configured to minify" do
            before { Manager.stub :minify? => true }

            it "is the result of calling its own #minify method" do
              reference.should_receive(:minify).and_return "tiny output"
              subject.should == "tiny output"
            end

          end
        end

        context "and the file contains URLs relative to the stylesheet" do
          let(:raw_content) { "body { background: url(background.gif); }" }

          it "makes the URLs relative to RELATIVE_URL_ROOT and the member name" do
            should contain_string "url(#{StylesheetReference::RELATIVE_URL_ROOT}/thing/background.gif)"
          end
        end

        context "and the file contains URLs within directories relative to the stylesheet" do
          let(:raw_content) { "body { background: url(a/b/background.gif); }" }

          it "makes the URLs relative to RELATIVE_URL_ROOT and the member name" do
            should contain_string "url(#{StylesheetReference::RELATIVE_URL_ROOT}/thing/a/b/background.gif)"
          end
        end

        context "and the file contains URLs with dots, relative to the stylesheet" do
          let(:raw_content) { "body { background: url(../a/b/background.gif); }" }

          it "makes the URLs relative to RELATIVE_URL_ROOT and the member name, ignoring leading dots" do
            should contain_string "url(#{StylesheetReference::RELATIVE_URL_ROOT}/thing/a/b/background.gif)"
          end
        end

        context "and the file contains full URLs with hosts" do
          let(:raw_content) { "body { background: url(http://www.example.com/background.gif); }" }

          it "leaves the URLs unchanged" do
            should contain_string "url(http://www.example.com/background.gif)"
          end
        end
      end
    end

  end
end
