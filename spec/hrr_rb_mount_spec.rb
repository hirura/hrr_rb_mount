require "tmpdir"
require "fileutils"

RSpec.describe HrrRbMount do
  it "has a version number" do
    expect(HrrRbMount::VERSION).not_to be nil
  end

  it "has constants module" do
    expect(HrrRbMount::Constants).not_to be nil
  end

  it "has constants defined in Constants module" do
    expect(HrrRbMount::Constants.constants).not_to be_empty
  end

  it "includes Constants module" do
    expect(HrrRbMount.ancestors).to include HrrRbMount::Constants
  end

  describe ".mount" do
    before :example do
      @tmpdir = Dir.mktmpdir
    end

    after :example do
      system "mountpoint -q #{@tmpdir} && umount #{@tmpdir}"
      FileUtils.remove_entry @tmpdir
    end

    it "raises an ArgumentError when takes 2 args" do
      expect{ HrrRbMount.mount "tmpfs", @tmpdir }.to raise_error ArgumentError
    end

    it "takes 3 args" do
      expect( HrrRbMount.mount "tmpfs", @tmpdir, "tmpfs" ).to eq 0
    end

    it "takes 4 args" do
      expect( HrrRbMount.mount "tmpfs", @tmpdir, "tmpfs", 0 ).to eq 0
    end

    it "takes 5 args" do
      expect( HrrRbMount.mount "tmpfs", @tmpdir, "tmpfs", 0, "" ).to eq 0
    end

    it "raises an ArgumentError when takes 6 args" do
      expect{ HrrRbMount.mount "tmpfs", @tmpdir, "tmpfs", 0, "", "dummy" }.to raise_error ArgumentError
    end

    context "when filesystemtype is tmpfs" do
      let(:source){ "tmpfs" }
      let(:target){ @tmpdir }
      let(:filesystemtype){ "tmpfs" }

      it "mounts tmpfs" do
        expect( HrrRbMount.mount source, target, filesystemtype ).to eq 0
        expect(system "mountpoint -q #{@tmpdir}").to be true
      end
    end

    context "when flags are specified" do
      let(:source){ "tmpfs" }
      let(:target){ @tmpdir }
      let(:filesystemtype){ "tmpfs" }
      let(:flags){ HrrRbMount::Constants::NOEXEC | HrrRbMount::Constants::RDONLY }

      it "mounts following the flags" do
        expect( HrrRbMount.mount source, target, filesystemtype, flags ).to eq 0
        expect(system "mountpoint -q #{@tmpdir}").to be true
        expect(system "touch #{File.join(@tmpdir, "test")} >/dev/null 2>&1").to be false
      end
    end

    context "when data is specified" do
      let(:source){ "tmpfs" }
      let(:target){ @tmpdir }
      let(:filesystemtype){ "tmpfs" }
      let(:flags){ 0 }
      let(:data){ "size=100k" }

      it "mounts following the data" do
        expect( HrrRbMount.mount source, target, filesystemtype, flags, data ).to eq 0
        expect(system "mountpoint -q #{@tmpdir}").to be true
        expect(system "dd if=/dev/zero of=#{File.join(@tmpdir, "test")} bs=100k count=101 >/dev/null 2>&1").to be false
      end
    end

    context "when flags and data are specified" do
      let(:source){ "tmpfs" }
      let(:target){ @tmpdir }
      let(:filesystemtype){ "tmpfs" }
      let(:flags){ HrrRbMount::Constants::NOEXEC }
      let(:data){ "size=100k" }

      it "mounts following the flags and the data" do
        expect( HrrRbMount.mount source, target, filesystemtype, flags, data ).to eq 0
        expect(system "mountpoint -q #{@tmpdir}").to be true
        expect(system "touch #{File.join(@tmpdir, "test")} >/dev/null 2>&1").to be true
        expect(system "chmod +x #{File.join(@tmpdir, "test")} >/dev/null 2>&1").to be true
        expect(system "#{File.join(@tmpdir, "test")} >/dev/null 2>&1").to be false
      end
    end
  end

  describe ".umount" do
    before :example do
      @tmpdir = Dir.mktmpdir
      system "mount -t tmpfs tmpfs #{@tmpdir}"
    end

    after :example do
      system "mountpoint -q #{@tmpdir} && umount #{@tmpdir}"
      FileUtils.remove_entry @tmpdir
    end

    it "raises an ArgumentError when takes 0 args" do
      expect{ HrrRbMount.umount }.to raise_error ArgumentError
    end

    it "takes 1 args" do
      expect( HrrRbMount.umount @tmpdir ).to eq 0
    end

    it "takes 2 args" do
      expect( HrrRbMount.umount @tmpdir, 0 ).to eq 0
    end

    it "raises an ArgumentError when takes 3 args" do
      expect{ HrrRbMount.umount @tmpdir, 0, "dummy" }.to raise_error ArgumentError
    end

    it "umounts the target" do
      expect( HrrRbMount.umount @tmpdir ).to eq 0
      expect(system "mountpoint -q #{@tmpdir}").to be false
    end
  end
end
