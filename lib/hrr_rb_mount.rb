require "hrr_rb_mount/version"
require "hrr_rb_mount/hrr_rb_mount"

# A wrapper around mount and umount. See mount(2) and umount(2) for details.
#
# @example
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

  # A wrapper around mount --remount mountpoint command.
  #
  # @example
  #   HrrRbMount.remount "mountpoint" # => 0
  #
  # @param mountpoint [String] The location (a directory or file) specified by the pathname.
  # @param mountflags [Integer] The umount operation is performed depending on the bits specified in the mountflags.
  # @param data [String] Per filesystem options.
  # @return [Integer] 0.
  # @raise [Errno::EXXX] A SystemCallError is raised when the operation failed.
  def self.remount mountpoint, mountflags=0, data=""
    mount "none", mountpoint, nil, REMOUNT | mountflags, data
  end

  # A wrapper around mount --move source target command.
  #
  # @example
  #   HrrRbMount.move "source", "target" # => 0
  #
  # @param source [String] The pathname referring to a device or a pathname of a directory or file, or a dummy string.
  # @param target [String] The location (a directory or file) specified by the pathname.
  # @param mountflags [Integer] The umount operation is performed depending on the bits specified in the mountflags.
  # @param data [String] Per filesystem options.
  # @return [Integer] 0.
  # @raise [Errno::EXXX] A SystemCallError is raised when the operation failed.
  def self.move source, target, mountflags=0, data=""
    mount source, target, nil, MOVE | mountflags, data
  end

  # A wrapper around mount --bind source target command.
  #
  # @example
  #   HrrRbMount.bind "source", "target" # => 0
  #
  # @param source [String] The pathname referring to a device or a pathname of a directory or file, or a dummy string.
  # @param target [String] The location (a directory or file) specified by the pathname.
  # @param mountflags [Integer] The mount operation is performed depending on the bits specified in the mountflags.
  # @param data [String] Per filesystem options.
  # @return [Integer] 0.
  # @raise [Errno::EXXX] A SystemCallError is raised when the operation failed.
  def self.bind source, target, mountflags=0, data=""
    mount source, target, nil, BIND | mountflags, data
  end

  # A wrapper around mount --rbind source target command.
  #
  # @example
  #   HrrRbMount.rbind "source", "target" # => 0
  #
  # @param source [String] The pathname referring to a device or a pathname of a directory or file, or a dummy string.
  # @param target [String] The location (a directory or file) specified by the pathname.
  # @param mountflags [Integer] The mount operation is performed depending on the bits specified in the mountflags.
  # @param data [String] Per filesystem options.
  # @return [Integer] 0.
  # @raise [Errno::EXXX] A SystemCallError is raised when the operation failed.
  def self.rbind source, target, mountflags=0, data=""
    mount source, target, nil, BIND | REC | mountflags, data
  end

  # A wrapper around mount --make-shared mountpoint command.
  #
  # @example
  #   HrrRbMount.make_shared "mountpoint" # => 0
  #
  # @param mountpoint [String] The location (a directory or file) specified by the pathname.
  # @return [Integer] 0.
  # @raise [Errno::EXXX] A SystemCallError is raised when the operation failed.
  def self.make_shared mountpoint
    mount "none", mountpoint, nil, SHARED
  end

  # A wrapper around mount --make-slave mountpoint command.
  #
  # @example
  #   HrrRbMount.make_slave "mountpoint" # => 0
  #
  # @param mountpoint [String] The location (a directory or file) specified by the pathname.
  # @return [Integer] 0.
  # @raise [Errno::EXXX] A SystemCallError is raised when the operation failed.
  def self.make_slave mountpoint
    mount "none", mountpoint, nil, SLAVE
  end

  # A wrapper around mount --make-private mountpoint command.
  #
  # @example
  #   HrrRbMount.make_private "mountpoint" # => 0
  #
  # @param mountpoint [String] The location (a directory or file) specified by the pathname.
  # @return [Integer] 0.
  # @raise [Errno::EXXX] A SystemCallError is raised when the operation failed.
  def self.make_private mountpoint
    mount "none", mountpoint, nil, PRIVATE
  end

  # A wrapper around mount --make-unbindable mountpoint command.
  #
  # @example
  #   HrrRbMount.make_unbindable "mountpoint" # => 0
  #
  # @param mountpoint [String] The location (a directory or file) specified by the pathname.
  # @return [Integer] 0.
  # @raise [Errno::EXXX] A SystemCallError is raised when the operation failed.
  def self.make_unbindable mountpoint
    mount "none", mountpoint, nil, UNBINDABLE
  end

  # A wrapper around mount --make-rshared mountpoint command.
  #
  # @example
  #   HrrRbMount.make_rshared "mountpoint" # => 0
  #
  # @param mountpoint [String] The location (a directory or file) specified by the pathname.
  # @return [Integer] 0.
  # @raise [Errno::EXXX] A SystemCallError is raised when the operation failed.
  def self.make_rshared mountpoint
    mount "none", mountpoint, nil, REC | SHARED
  end

  # A wrapper around mount --make-rslave mountpoint command.
  #
  # @example
  #   HrrRbMount.make_rslave "mountpoint" # => 0
  #
  # @param mountpoint [String] The location (a directory or file) specified by the pathname.
  # @return [Integer] 0.
  # @raise [Errno::EXXX] A SystemCallError is raised when the operation failed.
  def self.make_rslave mountpoint
    mount "none", mountpoint, nil, REC | SLAVE
  end

  # A wrapper around mount --make-rprivate mountpoint command.
  #
  # @example
  #   HrrRbMount.make_rprivate "mountpoint" # => 0
  #
  # @param mountpoint [String] The location (a directory or file) specified by the pathname.
  # @return [Integer] 0.
  # @raise [Errno::EXXX] A SystemCallError is raised when the operation failed.
  def self.make_rprivate mountpoint
    mount "none", mountpoint, nil, REC | PRIVATE
  end

  # A wrapper around mount --make-runbindable mountpoint command.
  #
  # @example
  #   HrrRbMount.make_runbindable "mountpoint" # => 0
  #
  # @param mountpoint [String] The location (a directory or file) specified by the pathname.
  # @return [Integer] 0.
  # @raise [Errno::EXXX] A SystemCallError is raised when the operation failed.
  def self.make_runbindable mountpoint
    mount "none", mountpoint, nil, REC | UNBINDABLE
  end

  # Returns true if the target directory or file is a mountpoint. Otherwise, returns false.
  #
  # Internally, uses /proc/self/mountinfo file to detect if the target is a mountpoint.
  #
  # When the file is not available, then uses stat(2).
  # In this case, bind mount is not able to be detected.
  #
  # @example
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
