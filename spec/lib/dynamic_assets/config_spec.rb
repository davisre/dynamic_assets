require 'spec_helper'

describe DynamicAssets::Config do
  subject         { Object.new.extend(DynamicAssets::Config).tap { |m| m.init yml_path } }
  let(:yml_path)  { "/yml/path" }


  context "when the yml file does not exist" do
    before { File.stub(:exists?).with(yml_path).and_return false }

    it "#asset_references_for_group_key works but returns nil" do
      subject.asset_references_for_group_key(:stylesheets, :base).should be_nil
    end

    it "#asset_reference_for_name works but returns nil" do
      subject.asset_reference_for_name(:stylesheets, "sheet1").should be_nil
    end
  end


  context "when the yml file exists" do
    let(:yml) { {} }
    before do
      File.stub(:exists?).with(yml_path).and_return true
      YAML.stub(:load_file).with(yml_path).and_return yml
    end

    context "and contains no config vars" do
      its(:combine_asset_groups?) { should be_true }
      its(:minify?)               { should be_true }
      its(:cache?)                { should be_true }

      context "and contains one group of two stylesheets" do
        before { yml["stylesheets"] = [{ "base" => ["sheet1", "sheet2"] }] }

        it "instantiates one StylesheetReference" do
          DynamicAssets::StylesheetReference.should_receive(:new).once.and_return "a Style Ref"
          subject
        end

        it "#asset_references_for_group_key returns one stylesheet reference for the group" do
          subject.asset_references_for_group_key(:stylesheets, :base).length.should == 1
        end

        it "#asset_reference_for_name returns one stylesheet reference for the grouped sheet" do
          subject.asset_reference_for_name(:stylesheets, "base").should_not be_nil
        end

        it "#asset_reference_for_name returns no stylesheet reference for an individual sheet" do
          subject.asset_reference_for_name(:stylesheets, "sheet1").should be_nil
        end

        context "and contains one group of three javascripts" do
          before { yml["javascripts"] = [{ "base" => ["script1", "script2", "script3"] }] }

          it "instantiates one JavascriptReference" do
            DynamicAssets::JavascriptReference.should_receive(:new).once.and_return "a JavaScript Ref"
            subject
          end

          it "#asset_references_for_group_key returns one javascript reference for the group" do
            subject.asset_references_for_group_key(:javascripts, :base).length.should == 1
          end

          it "#asset_reference_for_name returns one javascript reference for the grouped script" do
            subject.asset_reference_for_name(:javascripts, "base").should_not be_nil
          end

          it "#asset_reference_for_name returns no javascript reference for an individual script" do
            subject.asset_reference_for_name(:javascripts, "script2").should be_nil
          end
        end

      end

    end

    context "when the yml file contains config vars that set minify to false" do
      let(:yml) { { "config" => { Rails.env => { "minify" => false } } } }

      its(:combine_asset_groups?) { should be_true }
      its(:minify?)               { should be_false }
      its(:cache?)                { should be_true }
    end

    context "when the yml file contains config vars that set cache to false" do
      let(:yml) { { "config" => { Rails.env => { "cache" => false } } } }

      its(:combine_asset_groups?) { should be_true }
      its(:minify?)               { should be_true }
      its(:cache?)                { should be_false }
    end

    context "when the yml file contains config vars that set combine_asset_groups to false" do
      let(:yml) { { "config" => { Rails.env => { "combine_asset_groups" => false } } } }

      its(:combine_asset_groups?) { should be_false }
      its(:minify?)               { should be_true }
      its(:cache?)                { should be_true }

      context "and contains one group of two stylesheets" do
        before { yml["stylesheets"] = [{ "base" => ["sheet1", "sheet2"] }] }

        it "instantiates two StylesheetReferences" do
          DynamicAssets::StylesheetReference.should_receive(:new).twice.and_return "a Style Ref"
          subject
        end

        it "#asset_references_for_group_key returns two stylesheet references for the group" do
          subject.asset_references_for_group_key(:stylesheets, :base).length.should == 2
        end

        it "#asset_reference_for_name returns no stylesheet reference for the grouped sheet" do
          subject.asset_reference_for_name(:stylesheets, "base").should be_nil
        end

        it "#asset_reference_for_name returns a stylesheet reference for an individual sheet" do
          subject.asset_reference_for_name(:stylesheets, "sheet1").should_not be_nil
        end

        context "and contains one group of three javascripts" do
          before { yml["javascripts"] = [{ "base" => ["script1", "script2", "script3"] }] }

          it "instantiates three JavascriptReferences" do
            DynamicAssets::JavascriptReference.should_receive(:new).exactly(3).times.
              and_return "a JavaScript Ref"
            subject
          end

          it "#asset_references_for_group_key returns three javascript references for the group" do
            subject.asset_references_for_group_key(:javascripts, :base).length.should == 3
          end

          it "#asset_reference_for_name returns no javascript reference for the grouped script" do
            subject.asset_reference_for_name(:javascripts, "base").should be_nil
          end

          it "#asset_reference_for_name returns a javascript reference for an individual script" do
            subject.asset_reference_for_name(:javascripts, "script2").should_not be_nil
          end
        end

      end
    end

  end

end
