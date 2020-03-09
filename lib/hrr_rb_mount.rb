require "hrr_rb_mount/version"
require "hrr_rb_mount/hrr_rb_mount"

# A wrapper around mount and umount. See mount(2) and umount(2) for details.
#
# == Synopsis:
#   require "hrr_rb_mount"
#
#   flags = HrrRbMount::NOEXEC
#   HrrRbMount.mount "tmpfs", "/path/to/target", "tmpfs", flags, "size=1M" # => 0
#   HrrRbMount.mountpoint? "/path/to/target"                               # => true
#   HrrRbMount.umount "/path/to/target"                                    # => 0
#
module HrrRbMount

  # Constants that represent the flags for mount and umount operations.
  module Constants
  end

  # The path to /proc/self/mountinfo.
  PROC_MOUNTINFO_PATH = "/proc/self/mountinfo"

  # Returns true if the target directory or file is a mountpoint. Otherwise, returns false.
  #
  # Internally, uses /proc/self/mountinfo file to detect if the target is a mountpoint.
  #
  # When the file is not available, then uses stat(2).
  # In this case, bind mount is not able to be detected.
  #
  # == Synopsis:
  #   HrrRbMount.mountpoint? "/proc"   # => true
  #   HrrRbMount.mountpoint? "/proc/1" # => false
  #
  # @param target [String] The target path to be checked.
  # @param follow_symlinks [Boolean] Specifies whether to follow symlinks.
  # @return [Boolean] true or false
  # @raise [Errno::EXXX] A SystemCallError is raised when the operation failed.
  def self.mountpoint? target, follow_symlinks: true
    return false if (! follow_symlinks) && File.symlink?(target)
    begin
      if File.exist? PROC_MOUNTINFO_PATH
        tgt_abs_path = File.realpath(target)
        File.foreach(PROC_MOUNTINFO_PATH){ |line|
          break true if line.split(" ")[4] == tgt_abs_path
        } or false
      else
        parent = File.join(target, "..")
        st, pst = File.stat(target), File.stat(parent)
        st.dev != pst.dev || st.ino == pst.ino
      end
    rescue Errno::ENOENT, Errno::ENOTDIR
      false
    end
  end
end
