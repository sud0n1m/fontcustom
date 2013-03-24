require "spec_helper"

# Why are we calling FC::Util methods from the parent class?
# See note in /lib/fontcustom.rb. Stubbing occurs on FC::UTIL.
describe Fontcustom::Util do
  context "#gem_root" do
    it "should return $GEM_ROOT/lib/fontcustom/" do
      version = File.join(Fontcustom.gem_root, "version.rb")
      File.exists?(version).should be_true
    end
  end

  context "#verify_fontforge" do
    it "should raise error if fontforge isn't installed" do
      expect { Fontcustom.verify_fontforge(`which fontforgggggge`) }.to raise_error(Thor::Error, /install fontforge/)
    end
  end

  context "#verify_input_dir" do
    it "should raise error if input_dir doesn't exist" do
      expect { Fontcustom.verify_input_dir(fixture("does-not-exist")) }.to raise_error(Thor::Error, /doesn't exist/)
    end

    it "should raise error if input_dir doesn't contain vectors" do
      expect { Fontcustom.verify_input_dir(fixture("empty")) }.to raise_error(Thor::Error, /doesn't contain any vectors/)
    end
  end

  context "#verify_output_dir" do
    it "should raise error if output_dir isn't a directory" do 
      output = fixture("not-a-dir")
      expect { Fontcustom.verify_output_dir(output) }.to raise_error(Thor::Error, /isn't a directory/)
    end

    it "should call #reset_output_dir if output_dir exists" do
      output = fixture("mixed-output")
      Fontcustom::UTIL.stub(:reset_output_dir)
      Fontcustom::UTIL.should_receive(:reset_output_dir).once.with(/#{output}/)
      Fontcustom.verify_output_dir(output)
    end

    it "should create output_dir if none exists" do
      output = fixture("does-not-exist")
      Fontcustom::UTIL.stub(:empty_directory)
      Fontcustom::UTIL.should_receive(:empty_directory).once.with(/#{output}/)
      Fontcustom.verify_output_dir(output)
    end
  end

  context "#reset_output_dir" do
    let(:output) { fixture("mixed-output") }

    it "should create .fontcustom-data if it doesn't exist" do
      Fontcustom::UTIL.stub(:add_file)
      Fontcustom::UTIL.should_receive(:add_file).once.with(/\.fontcustom-data/)
      Fontcustom.reset_output_dir(fixture("empty"))
    end

    it "should delete files specified in .fontcustom-data" do
      Fontcustom::UTIL.stub(:remove_file)
      Fontcustom::UTIL.stub(:clear_data_file)
      Fontcustom::UTIL.should_receive(:remove_file).exactly(5).times
      Fontcustom.reset_output_dir(output)
    end

    it "should not delete non-generated files" do
      Fontcustom::UTIL.stub(:remove_file)
      Fontcustom::UTIL.stub(:clear_data_file)
      Fontcustom::UTIL.should_not_receive(:remove_file).with(/(dont-delete-me-bro|another-font\.ttf)/)
      Fontcustom.reset_output_dir(output)
    end

    it "should clear the contents of .fontcustom-data" do
      Fontcustom::UTIL.stub(:remove_file)
      Fontcustom::UTIL.stub(:clear_data_file)
      Fontcustom::UTIL.should_receive(:clear_data_file).once.with(/\.fontcustom-data/)
      Fontcustom.reset_output_dir(output)
    end
  end
end
