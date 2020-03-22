require "tmpdir"
require "tempfile"
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
      @tmpdir1 = Dir.mktmpdir
      @tmpdir2 = Dir.mktmpdir
    end

    after :example do
      system "mountpoint -q #{@tmpdir1} && umount #{@tmpdir1}"
      system "mountpoint -q #{@tmpdir2} && umount #{@tmpdir2}"
      FileUtils.remove_entry @tmpdir1
      FileUtils.remove_entry @tmpdir2
    end

    it "raises an ArgumentError when takes 2 args" do
      expect{ HrrRbMount.mount "tmpfs", @tmpdir1 }.to raise_error ArgumentError
    end

    it "takes 3 args" do
      expect( HrrRbMount.mount "tmpfs", @tmpdir1, "tmpfs" ).to eq 0
    end

    it "takes 4 args" do
      expect( HrrRbMount.mount "tmpfs", @tmpdir1, "tmpfs", 0 ).to eq 0
    end

    it "takes 5 args" do
      expect( HrrRbMount.mount "tmpfs", @tmpdir1, "tmpfs", 0, "" ).to eq 0
    end

    it "raises an ArgumentError when takes 6 args" do
      expect{ HrrRbMount.mount "tmpfs", @tmpdir1, "tmpfs", 0, "", "dummy" }.to raise_error ArgumentError
    end

    context "when filesystemtype is tmpfs" do
      let(:source){ "tmpfs" }
      let(:target){ @tmpdir1 }
      let(:filesystemtype){ "tmpfs" }

      it "mounts tmpfs" do
        expect( HrrRbMount.mount source, target, filesystemtype ).to eq 0
        expect(system "mountpoint -q #{@tmpdir1}").to be true
      end
    end

    context "when flags are specified" do
      let(:source){ "tmpfs" }
      let(:target){ @tmpdir1 }
      let(:filesystemtype){ "tmpfs" }
      let(:flags){ HrrRbMount::Constants::NOEXEC | HrrRbMount::Constants::RDONLY }

      it "mounts following the flags" do
        expect( HrrRbMount.mount source, target, filesystemtype, flags ).to eq 0
        expect(system "mountpoint -q #{@tmpdir1}").to be true
        expect(system "touch #{File.join(@tmpdir1, "test")} >/dev/null 2>&1").to be false
      end
    end

    context "when data is specified" do
      let(:source){ "tmpfs" }
      let(:target){ @tmpdir1 }
      let(:filesystemtype){ "tmpfs" }
      let(:flags){ 0 }
      let(:data){ "size=100k" }

      it "mounts following the data" do
        expect( HrrRbMount.mount source, target, filesystemtype, flags, data ).to eq 0
        expect(system "mountpoint -q #{@tmpdir1}").to be true
        expect(system "dd if=/dev/zero of=#{File.join(@tmpdir1, "test")} bs=100k count=101 >/dev/null 2>&1").to be false
      end
    end

    context "when flags and data are specified" do
      let(:source){ "tmpfs" }
      let(:target){ @tmpdir1 }
      let(:filesystemtype){ "tmpfs" }
      let(:flags){ HrrRbMount::Constants::NOEXEC }
      let(:data){ "size=100k" }

      it "mounts following the flags and the data" do
        expect( HrrRbMount.mount source, target, filesystemtype, flags, data ).to eq 0
        expect(system "mountpoint -q #{@tmpdir1}").to be true
        expect(system "touch #{File.join(@tmpdir1, "test")} >/dev/null 2>&1").to be true
        expect(system "chmod +x #{File.join(@tmpdir1, "test")} >/dev/null 2>&1").to be true
        expect(system "#{File.join(@tmpdir1, "test")} >/dev/null 2>&1").to be false
      end
    end

    context "when filesystemtype is nil and the flag is the type that ignores it" do
      let(:source){ @tmpdir2 }
      let(:target){ @tmpdir1 }
      let(:filesystemtype){ nil }
      let(:flags){ HrrRbMount::Constants::BIND }

      it "mounts ignoring the filesystemtype and following the option" do
        expect( HrrRbMount.mount source, target, filesystemtype, flags ).to eq 0
        expect(system "mountpoint -q #{@tmpdir1}").to be true
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

  describe ".remount" do
    let(:mountpoint){ "dummy mountpoint" }

    context "when flags and data are not specified" do
      it "calls .mount with \"none\" source, mountpoint target, nil filesystemtype, and REMOUNT flag" do
        expect( HrrRbMount ).to receive(:mount).with("none", mountpoint, nil, HrrRbMount::Constants::REMOUNT, "").and_return(0).once
        expect( HrrRbMount.remount mountpoint ).to eq 0
      end
    end

    context "when flags and data are specified" do
      let(:flags){ HrrRbMount::Constants::RDONLY }
      let(:data){ "dummy data" }

      it "calls .mount with \"none\" source, mountpoint target, nil filesystemtype, REMOUNT flag, and specified flags and data" do
        expect( HrrRbMount ).to receive(:mount).with("none", mountpoint, nil, HrrRbMount::Constants::REMOUNT | flags, data).and_return(0).once
        expect( HrrRbMount.remount mountpoint, flags, data ).to eq 0
      end
    end
  end

  describe ".move" do
    let(:source){ "dummy source" }
    let(:target){ "dummy target" }

    context "when flags and data are not specified" do
      it "calls .mount with source, target, nil filesystemtype, and MOVE flag" do
        expect( HrrRbMount ).to receive(:mount).with(source, target, nil, HrrRbMount::Constants::MOVE, "").and_return(0).once
        expect( HrrRbMount.move source, target ).to eq 0
      end
    end

    context "when flags and data are specified" do
      let(:flags){ HrrRbMount::Constants::RDONLY }
      let(:data){ "dummy data" }

      it "calls .mount with source, target, nil filesystemtype, MOVE flag, and specified flags and data" do
        expect( HrrRbMount ).to receive(:mount).with(source, target, nil, HrrRbMount::Constants::MOVE | flags, data).and_return(0).once
        expect( HrrRbMount.move source, target, flags, data ).to eq 0
      end
    end
  end

  describe ".bind" do
    let(:source){ "dummy source" }
    let(:target){ "dummy target" }

    context "when flags and data are not specified" do
      it "calls .mount with source, target, nil filesystemtype, and BIND flag" do
        expect( HrrRbMount ).to receive(:mount).with(source, target, nil, HrrRbMount::Constants::BIND, "").and_return(0).once
        expect( HrrRbMount.bind source, target ).to eq 0
      end
    end

    context "when flags and data are specified" do
      let(:flags){ HrrRbMount::Constants::RDONLY }
      let(:data){ "dummy data" }

      it "calls .mount with source, target, nil filesystemtype, BIND flag, and specified flags and data" do
        expect( HrrRbMount ).to receive(:mount).with(source, target, nil, HrrRbMount::Constants::BIND | flags, data).and_return(0).once
        expect( HrrRbMount.bind source, target, flags, data ).to eq 0
      end
    end
  end

  describe ".rbind" do
    let(:source){ "dummy source" }
    let(:target){ "dummy target" }

    context "when flags and data are not specified" do
      it "calls .mount with source, target, nil filesystemtype, and BIND | REC flags" do
        expect( HrrRbMount ).to receive(:mount).with(source, target, nil, HrrRbMount::Constants::BIND | HrrRbMount::Constants::REC, "").and_return(0).once
        expect( HrrRbMount.rbind source, target ).to eq 0
      end
    end

    context "when flags and data are specified" do
      let(:flags){ HrrRbMount::Constants::RDONLY }
      let(:data){ "dummy data" }

      it "calls .mount with source, target, nil filesystemtype, BIND | REC flags, and specified flags and data" do
        expect( HrrRbMount ).to receive(:mount).with(source, target, nil, HrrRbMount::Constants::BIND | HrrRbMount::Constants::REC | flags, data).and_return(0).once
        expect( HrrRbMount.rbind source, target, flags, data ).to eq 0
      end
    end
  end

  describe ".make_shared" do
    let(:mountpoint){ "dummy mountpoint" }

    it "calls .mount with \"none\" source, mountpoint target, nil filesystemtype, and SHARED flag" do
      expect( HrrRbMount ).to receive(:mount).with("none", mountpoint, nil, HrrRbMount::Constants::SHARED).and_return(0).once
      expect( HrrRbMount.make_shared mountpoint ).to eq 0
    end
  end

  describe ".make_slave" do
    let(:mountpoint){ "dummy mountpoint" }

    it "calls .mount with \"none\" source, mountpoint target, nil filesystemtype, and SLAVE flag" do
      expect( HrrRbMount ).to receive(:mount).with("none", mountpoint, nil, HrrRbMount::Constants::SLAVE).and_return(0).once
      expect( HrrRbMount.make_slave mountpoint ).to eq 0
    end
  end

  describe ".make_private" do
    let(:mountpoint){ "dummy mountpoint" }

    it "calls .mount with \"none\" source, mountpoint target, nil filesystemtype, and PRIVATE flag" do
      expect( HrrRbMount ).to receive(:mount).with("none", mountpoint, nil, HrrRbMount::Constants::PRIVATE).and_return(0).once
      expect( HrrRbMount.make_private mountpoint ).to eq 0
    end
  end

  describe ".make_unbindable" do
    let(:mountpoint){ "dummy mountpoint" }

    it "calls .mount with \"none\" source, mountpoint target, nil filesystemtype, and UNBINDABLE flag" do
      expect( HrrRbMount ).to receive(:mount).with("none", mountpoint, nil, HrrRbMount::Constants::UNBINDABLE).and_return(0).once
      expect( HrrRbMount.make_unbindable mountpoint ).to eq 0
    end
  end

  describe ".make_rshared" do
    let(:mountpoint){ "dummy mountpoint" }

    it "calls .mount with \"none\" source, mountpoint target, nil filesystemtype, and REC | SHARED flags" do
      expect( HrrRbMount ).to receive(:mount).with("none", mountpoint, nil, HrrRbMount::Constants::REC | HrrRbMount::Constants::SHARED).and_return(0).once
      expect( HrrRbMount.make_rshared mountpoint ).to eq 0
    end
  end

  describe ".make_rslave" do
    let(:mountpoint){ "dummy mountpoint" }

    it "calls .mount with \"none\" source, mountpoint target, nil filesystemtype, and REC | SLAVE flags" do
      expect( HrrRbMount ).to receive(:mount).with("none", mountpoint, nil, HrrRbMount::Constants::REC | HrrRbMount::Constants::SLAVE).and_return(0).once
      expect( HrrRbMount.make_rslave mountpoint ).to eq 0
    end
  end

  describe ".make_rprivate" do
    let(:mountpoint){ "dummy mountpoint" }

    it "calls .mount with \"none\" source, mountpoint target, nil filesystemtype, and REC | PRIVATE flags" do
      expect( HrrRbMount ).to receive(:mount).with("none", mountpoint, nil, HrrRbMount::Constants::REC | HrrRbMount::Constants::PRIVATE).and_return(0).once
      expect( HrrRbMount.make_rprivate mountpoint ).to eq 0
    end
  end

  describe ".make_runbindable" do
    let(:mountpoint){ "dummy mountpoint" }

    it "calls .mount with \"none\" source, mountpoint target, nil filesystemtype, and REC | UNBINDABLE flags" do
      expect( HrrRbMount ).to receive(:mount).with("none", mountpoint, nil, HrrRbMount::Constants::REC | HrrRbMount::Constants::UNBINDABLE).and_return(0).once
      expect( HrrRbMount.make_runbindable mountpoint ).to eq 0
    end
  end

  describe ".mountpoint?" do
    before :context do
      @tmpdir1  = Dir.mktmpdir
      @tmpdir2  = Dir.mktmpdir
      @tmpdir3  = Dir.mktmpdir
      @tmpdir4  = Dir.mktmpdir
      @tmpdir5  = @tmpdir1 + "link"
      @tmpdir6  = @tmpdir2 + "link"
      @tmpdir7  = @tmpdir4 + "link"
      @tmpdir8  = @tmpdir5 + "link"
      @tmpdir9  = @tmpdir6 + "link"
      @tmpdir10 = @tmpdir7 + "link"
      @tmpdir11 = @tmpdir1 + "nonelink"
      @tmpfile1 = Tempfile.new "f"
      @tmpfile2 = Tempfile.new "f"
      @tmpfile3 = @tmpfile2.path + "link"
      system "mount -t tmpfs tmpfs #{@tmpdir1}"
      system "mount --bind #{@tmpdir3} #{@tmpdir4}"
      system "ln -s #{@tmpdir1} #{@tmpdir5}"
      system "ln -s #{@tmpdir2} #{@tmpdir6}"
      system "ln -s #{@tmpdir4} #{@tmpdir7}"
      system "ln -s #{@tmpdir5} #{@tmpdir8}"
      system "ln -s #{@tmpdir6} #{@tmpdir9}"
      system "ln -s #{@tmpdir7} #{@tmpdir10}"
      system "ln -s #{@tmpdir1}none #{@tmpdir11}"
      system "mount --bind #{@tmpfile1.path} #{@tmpfile2.path}"
      system "ln -s #{@tmpfile2.path} #{@tmpfile3}"
    end

    after :context do
      [@tmpdir5, @tmpdir6, @tmpdir7, @tmpdir8, @tmpdir9, @tmpdir10, @tmpdir11].reverse.each{ |tmpdir|
        system "unlink #{tmpdir}"
      }
      [@tmpdir1, @tmpdir2, @tmpdir3, @tmpdir4].reverse.each{ |tmpdir|
        system "mountpoint -q #{tmpdir} && umount #{tmpdir}"
        FileUtils.remove_entry tmpdir
      }
      [@tmpfile3].reverse.each{ |tmpfile|
        system "unlink #{tmpfile}"
      }
      [@tmpfile1, @tmpfile2].reverse.each{ |tmpfile|
        system "mountpoint -q #{tmpfile.path} && umount #{tmpfile.path}"
        tmpfile.close!
      }
    end

    context "when follow_symlinks is not specified" do
      context "when /proc/self/mountinfo exists" do
        context "when target is \"/\"" do
          it "returns true" do
            expect( HrrRbMount.mountpoint? "/" ).to be true
          end
        end

        context "when target is \"\"" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? "" ).to be false
          end
        end

        context "when target is mounted" do
          it "returns true" do
            expect( HrrRbMount.mountpoint? @tmpdir1 ).to be true
          end
        end

        context "when target is not mounted" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpdir2 ).to be false
          end
        end

        context "when target is bind-mounted" do
          it "returns true" do
            expect( HrrRbMount.mountpoint? @tmpdir4 ).to be true
          end
        end

        context "when target is symlink to mounted" do
          it "returns true" do
            expect( HrrRbMount.mountpoint? @tmpdir5 ).to be true
          end
        end

        context "when target is symlink to not mounted" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpdir6 ).to be false
          end
        end

        context "when target is symlink to bind-mounted" do
          it "returns true" do
            expect( HrrRbMount.mountpoint? @tmpdir7 ).to be true
          end
        end

        context "when target is symlink to symlink to mounted" do
          it "returns true" do
            expect( HrrRbMount.mountpoint? @tmpdir8 ).to be true
          end
        end

        context "when target is symlink to symlink to not mounted" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpdir9 ).to be false
          end
        end

        context "when target is symlink to symlink to bind-mounted" do
          it "returns true" do
            expect( HrrRbMount.mountpoint? @tmpdir10 ).to be true
          end
        end

        context "when target is symlink to none" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpdir11 ).to be false
          end
        end

        context "when target is not mounted file" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpfile1.path ).to be false
          end
        end

        context "when target is bind-mounted file" do
          it "returns true" do
            expect( HrrRbMount.mountpoint? @tmpfile2.path ).to be true
          end
        end

        context "when target is symlink to bind-mounted file" do
          it "returns true" do
            expect( HrrRbMount.mountpoint? @tmpfile3 ).to be true
          end
        end
      end

      context "when /proc/self/mountinfo does not exist" do
        before :context do
          @proc_mountinfo_path_bak = HrrRbMount.send(:remove_const, :PROC_MOUNTINFO_PATH)
          HrrRbMount.const_set(:PROC_MOUNTINFO_PATH, "")
        end

        after :context do
          HrrRbMount.send(:remove_const, :PROC_MOUNTINFO_PATH)
          HrrRbMount.const_set(:PROC_MOUNTINFO_PATH, @proc_mountinfo_path_bak)
        end

        context "when target is \"/\"" do
          it "returns true" do
            expect( HrrRbMount.mountpoint? "/" ).to be true
          end
        end

        context "when target is \"\"" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? "" ).to be false
          end
        end

        context "when target is mounted" do
          it "returns true" do
            expect( HrrRbMount.mountpoint? @tmpdir1 ).to be true
          end
        end

        context "when target is not mounted" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpdir2 ).to be false
          end
        end

        context "when target is bind-mounted" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpdir4 ).to be false
          end
        end

        context "when target is symlink to mounted" do
          it "returns true" do
            expect( HrrRbMount.mountpoint? @tmpdir5 ).to be true
          end
        end

        context "when target is symlink to not mounted" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpdir6 ).to be false
          end
        end

        context "when target is symlink to bind-mounted" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpdir7 ).to be false
          end
        end

        context "when target is symlink to symlink to mounted" do
          it "returns true" do
            expect( HrrRbMount.mountpoint? @tmpdir8 ).to be true
          end
        end

        context "when target is symlink to symlink to not mounted" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpdir9 ).to be false
          end
        end

        context "when target is symlink to symlink to bind-mounted" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpdir10 ).to be false
          end
        end

        context "when target is symlink to none" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpdir11 ).to be false
          end
        end

        context "when target is not mounted file" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpfile1.path ).to be false
          end
        end

        context "when target is bind-mounted file" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpfile2.path ).to be false
          end
        end

        context "when target is symlink to bind-mounted file" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpfile3 ).to be false
          end
        end
      end
    end

    context "when follow_symlinks is true" do
      let(:follow_symlinks){ true }

      context "when /proc/self/mountinfo exists" do
        context "when target is \"/\"" do
          it "returns true" do
            expect( HrrRbMount.mountpoint? "/", follow_symlinks: follow_symlinks ).to be true
          end
        end

        context "when target is \"\"" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? "", follow_symlinks: follow_symlinks ).to be false
          end
        end

        context "when target is mounted" do
          it "returns true" do
            expect( HrrRbMount.mountpoint? @tmpdir1, follow_symlinks: follow_symlinks ).to be true
          end
        end

        context "when target is not mounted" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpdir2, follow_symlinks: follow_symlinks ).to be false
          end
        end

        context "when target is bind-mounted" do
          it "returns true" do
            expect( HrrRbMount.mountpoint? @tmpdir4, follow_symlinks: follow_symlinks ).to be true
          end
        end

        context "when target is symlink to mounted" do
          it "returns true" do
            expect( HrrRbMount.mountpoint? @tmpdir5, follow_symlinks: follow_symlinks ).to be true
          end
        end

        context "when target is symlink to not mounted" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpdir6, follow_symlinks: follow_symlinks ).to be false
          end
        end

        context "when target is symlink to bind-mounted" do
          it "returns true" do
            expect( HrrRbMount.mountpoint? @tmpdir7, follow_symlinks: follow_symlinks ).to be true
          end
        end

        context "when target is symlink to symlink to mounted" do
          it "returns true" do
            expect( HrrRbMount.mountpoint? @tmpdir8, follow_symlinks: follow_symlinks ).to be true
          end
        end

        context "when target is symlink to symlink to not mounted" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpdir9, follow_symlinks: follow_symlinks ).to be false
          end
        end

        context "when target is symlink to symlink to bind-mounted" do
          it "returns true" do
            expect( HrrRbMount.mountpoint? @tmpdir10, follow_symlinks: follow_symlinks ).to be true
          end
        end

        context "when target is symlink to none" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpdir11, follow_symlinks: follow_symlinks ).to be false
          end
        end

        context "when target is not mounted file" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpfile1.path, follow_symlinks: follow_symlinks ).to be false
          end
        end

        context "when target is bind-mounted file" do
          it "returns true" do
            expect( HrrRbMount.mountpoint? @tmpfile2.path, follow_symlinks: follow_symlinks ).to be true
          end
        end

        context "when target is symlink to bind-mounted file" do
          it "returns true" do
            expect( HrrRbMount.mountpoint? @tmpfile3, follow_symlinks: follow_symlinks ).to be true
          end
        end
      end

      context "when /proc/self/mountinfo does not exist" do
        before :context do
          @proc_mountinfo_path_bak = HrrRbMount.send(:remove_const, :PROC_MOUNTINFO_PATH)
          HrrRbMount.const_set(:PROC_MOUNTINFO_PATH, "")
        end

        after :context do
          HrrRbMount.send(:remove_const, :PROC_MOUNTINFO_PATH)
          HrrRbMount.const_set(:PROC_MOUNTINFO_PATH, @proc_mountinfo_path_bak)
        end

        context "when target is \"/\"" do
          it "returns true" do
            expect( HrrRbMount.mountpoint? "/", follow_symlinks: follow_symlinks ).to be true
          end
        end

        context "when target is \"\"" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? "", follow_symlinks: follow_symlinks ).to be false
          end
        end

        context "when target is mounted" do
          it "returns true" do
            expect( HrrRbMount.mountpoint? @tmpdir1, follow_symlinks: follow_symlinks ).to be true
          end
        end

        context "when target is not mounted" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpdir2, follow_symlinks: follow_symlinks ).to be false
          end
        end

        context "when target is bind-mounted" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpdir4, follow_symlinks: follow_symlinks ).to be false
          end
        end

        context "when target is symlink to mounted" do
          it "returns true" do
            expect( HrrRbMount.mountpoint? @tmpdir5, follow_symlinks: follow_symlinks ).to be true
          end
        end

        context "when target is symlink to not mounted" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpdir6, follow_symlinks: follow_symlinks ).to be false
          end
        end

        context "when target is symlink to bind-mounted" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpdir7, follow_symlinks: follow_symlinks ).to be false
          end
        end

        context "when target is symlink to symlink to mounted" do
          it "returns true" do
            expect( HrrRbMount.mountpoint? @tmpdir8, follow_symlinks: follow_symlinks ).to be true
          end
        end

        context "when target is symlink to symlink to not mounted" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpdir9, follow_symlinks: follow_symlinks ).to be false
          end
        end

        context "when target is symlink to symlink to bind-mounted" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpdir10, follow_symlinks: follow_symlinks ).to be false
          end
        end

        context "when target is symlink to none" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpdir11, follow_symlinks: follow_symlinks ).to be false
          end
        end

        context "when target is not mounted file" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpfile1.path, follow_symlinks: follow_symlinks ).to be false
          end
        end

        context "when target is bind-mounted file" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpfile2.path, follow_symlinks: follow_symlinks ).to be false
          end
        end

        context "when target is symlink to bind-mounted file" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpfile3, follow_symlinks: follow_symlinks ).to be false
          end
        end
      end
    end

    context "when follow_symlinks is false" do
      let(:follow_symlinks){ false }

      context "when /proc/self/mountinfo exists" do
        context "when target is \"/\"" do
          it "returns true" do
            expect( HrrRbMount.mountpoint? "/", follow_symlinks: follow_symlinks ).to be true
          end
        end

        context "when target is \"\"" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? "", follow_symlinks: follow_symlinks ).to be false
          end
        end

        context "when target is mounted" do
          it "returns true" do
            expect( HrrRbMount.mountpoint? @tmpdir1, follow_symlinks: follow_symlinks ).to be true
          end
        end

        context "when target is not mounted" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpdir2, follow_symlinks: follow_symlinks ).to be false
          end
        end

        context "when target is bind-mounted" do
          it "returns true" do
            expect( HrrRbMount.mountpoint? @tmpdir4, follow_symlinks: follow_symlinks ).to be true
          end
        end

        context "when target is symlink to mounted" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpdir5, follow_symlinks: follow_symlinks ).to be false
          end
        end

        context "when target is symlink to not mounted" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpdir6, follow_symlinks: follow_symlinks ).to be false
          end
        end

        context "when target is symlink to bind-mounted" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpdir7, follow_symlinks: follow_symlinks ).to be false
          end
        end

        context "when target is symlink to symlink to mounted" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpdir8, follow_symlinks: follow_symlinks ).to be false
          end
        end

        context "when target is symlink to symlink to not mounted" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpdir9, follow_symlinks: follow_symlinks ).to be false
          end
        end

        context "when target is symlink to symlink to bind-mounted" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpdir10, follow_symlinks: follow_symlinks ).to be false
          end
        end

        context "when target is symlink to none" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpdir11, follow_symlinks: follow_symlinks ).to be false
          end
        end

        context "when target is not mounted file" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpfile1.path, follow_symlinks: follow_symlinks ).to be false
          end
        end

        context "when target is bind-mounted file" do
          it "returns true" do
            expect( HrrRbMount.mountpoint? @tmpfile2.path, follow_symlinks: follow_symlinks ).to be true
          end
        end

        context "when target is symlink to bind-mounted file" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpfile3, follow_symlinks: follow_symlinks ).to be false
          end
        end
      end

      context "when /proc/self/mountinfo does not exist" do
        before :context do
          @proc_mountinfo_path_bak = HrrRbMount.send(:remove_const, :PROC_MOUNTINFO_PATH)
          HrrRbMount.const_set(:PROC_MOUNTINFO_PATH, "")
        end

        after :context do
          HrrRbMount.send(:remove_const, :PROC_MOUNTINFO_PATH)
          HrrRbMount.const_set(:PROC_MOUNTINFO_PATH, @proc_mountinfo_path_bak)
        end

        context "when target is \"/\"" do
          it "returns true" do
            expect( HrrRbMount.mountpoint? "/", follow_symlinks: follow_symlinks ).to be true
          end
        end

        context "when target is \"\"" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? "", follow_symlinks: follow_symlinks ).to be false
          end
        end

        context "when target is mounted" do
          it "returns true" do
            expect( HrrRbMount.mountpoint? @tmpdir1, follow_symlinks: follow_symlinks ).to be true
          end
        end

        context "when target is not mounted" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpdir2, follow_symlinks: follow_symlinks ).to be false
          end
        end

        context "when target is bind-mounted" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpdir4, follow_symlinks: follow_symlinks ).to be false
          end
        end

        context "when target is symlink to mounted" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpdir5, follow_symlinks: follow_symlinks ).to be false
          end
        end

        context "when target is symlink to not mounted" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpdir6, follow_symlinks: follow_symlinks ).to be false
          end
        end

        context "when target is symlink to bind-mounted" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpdir7, follow_symlinks: follow_symlinks ).to be false
          end
        end

        context "when target is symlink to symlink to mounted" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpdir8, follow_symlinks: follow_symlinks ).to be false
          end
        end

        context "when target is symlink to symlink to not mounted" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpdir9, follow_symlinks: follow_symlinks ).to be false
          end
        end

        context "when target is symlink to symlink to bind-mounted" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpdir10, follow_symlinks: follow_symlinks ).to be false
          end
        end

        context "when target is symlink to none" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpdir11, follow_symlinks: follow_symlinks ).to be false
          end
        end

        context "when target is not mounted file" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpfile1.path, follow_symlinks: follow_symlinks ).to be false
          end
        end

        context "when target is bind-mounted file" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpfile2.path, follow_symlinks: follow_symlinks ).to be false
          end
        end

        context "when target is symlink to bind-mounted file" do
          it "returns false" do
            expect( HrrRbMount.mountpoint? @tmpfile3, follow_symlinks: follow_symlinks ).to be false
          end
        end
      end
    end
  end
end
