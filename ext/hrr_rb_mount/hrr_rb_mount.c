#include "hrr_rb_mount.h"
#include "sys/mount.h"

VALUE rb_mHrrRbMount;
VALUE rb_mHrrRbMountConst;

/*
 * A wrapper around mount system call.
 *
 * == Synopsis:
 *   HrrRbMount.mount "source", "target", "filesystemtype", mountflags, "data" # => 0
 *
 * @overload mount(source, target, filesystemtype, mountflags=0, data="") => 0
 *   @param source [String] The pathname referring to a device or a pathname of a directory or file, or a dummy string.
 *   @param target [String] The location (a directory or file) specified by the pathname.
 *   @param filesystemtype [String] The filesystem type, which is supported by the kernel.
 *   @param mountflags [Integer] The mount operation is performed depending on the bits specified in the mountflags.
 *   @param data [String] Per filesystem options.
 *   @return [Integer] 0.
 *   @raise [Errno::EXXX] A SystemCallError is raised when the operation failed.
 */
VALUE
hrr_rb_mount_mount(int argc, VALUE *argv, VALUE self)
{
  const char *source, *target, *filesystemtype, *data;
  unsigned long mountflags;

  rb_check_arity(argc, 3, 5);

  source         = StringValueCStr(argv[0]);
  target         = StringValueCStr(argv[1]);
  filesystemtype = StringValueCStr(argv[2]);
  mountflags     = argc < 4 ? 0 : NUM2ULONG(argv[3]);
  data           = argc < 5 ? "" : StringValueCStr(argv[4]);

  if (mount(source, target, filesystemtype, mountflags, data) < 0)
    rb_sys_fail("mount");

  return INT2FIX(0);
}

/*
 * A wrapper around umount system call.
 *
 * == Synopsis:
 *   HrrRbMount.umount "target", flags # => 0
 *
 * @overload umount(target, flags=0) => 0
 *   @param target [String] The location (a directory or file) specified by the pathname.
 *   @param flags [Integer] The umount operation is performed depending on the bits specified in the flags.
 *   @return [Integer] 0.
 *   @raise [Errno::EXXX] A SystemCallError is raised when the operation failed.
 */
VALUE
hrr_rb_mount_umount(int argc, VALUE *argv, VALUE self)
{
  const char *target;
  int flags;

  rb_check_arity(argc, 1, 2);

  target = StringValueCStr(argv[0]);
  flags  = argc < 2 ? 0 : NUM2INT(argv[1]);

  if (umount2(target, flags) < 0)
    rb_sys_fail("umount");

  return INT2FIX(0);
}

void
Init_hrr_rb_mount(void)
{
  rb_mHrrRbMount = rb_define_module("HrrRbMount");

  rb_define_singleton_method(rb_mHrrRbMount, "mount",  hrr_rb_mount_mount,  -1);
  rb_define_singleton_method(rb_mHrrRbMount, "umount", hrr_rb_mount_umount, -1);

  rb_mHrrRbMountConst = rb_define_module_under(rb_mHrrRbMount, "Constants");
  rb_include_module(rb_mHrrRbMount, rb_mHrrRbMountConst);

  /* This flag can be specified in mount. */
  rb_define_const(rb_mHrrRbMountConst, "REMOUNT",     INT2NUM(MS_REMOUNT)    );
  /* This flag can be specified in mount. */
  rb_define_const(rb_mHrrRbMountConst, "BIND",        INT2NUM(MS_BIND)       );
  /* This flag can be specified in mount. */
  rb_define_const(rb_mHrrRbMountConst, "SHARED",      INT2NUM(MS_SHARED)     );
  /* This flag can be specified in mount. */
  rb_define_const(rb_mHrrRbMountConst, "PRIVATE",     INT2NUM(MS_PRIVATE)    );
  /* This flag can be specified in mount. */
  rb_define_const(rb_mHrrRbMountConst, "SLAVE",       INT2NUM(MS_SLAVE)      );
  /* This flag can be specified in mount. */
  rb_define_const(rb_mHrrRbMountConst, "UNBINDABLE",  INT2NUM(MS_UNBINDABLE) );
  /* This flag can be specified in mount. */
  rb_define_const(rb_mHrrRbMountConst, "MOVE",        INT2NUM(MS_MOVE)       );
  /* This flag can be specified in mount. */
  rb_define_const(rb_mHrrRbMountConst, "DIRSYNC",     INT2NUM(MS_DIRSYNC)    );
  /* This flag can be specified in mount. */
  rb_define_const(rb_mHrrRbMountConst, "LAZYTIME",    INT2NUM(MS_LAZYTIME)   );
  /* This flag can be specified in mount. */
  rb_define_const(rb_mHrrRbMountConst, "MANDLOCK",    INT2NUM(MS_MANDLOCK)   );
  /* This flag can be specified in mount. */
  rb_define_const(rb_mHrrRbMountConst, "NOATIME",     INT2NUM(MS_NOATIME)    );
  /* This flag can be specified in mount. */
  rb_define_const(rb_mHrrRbMountConst, "NODEV",       INT2NUM(MS_NODEV)      );
  /* This flag can be specified in mount. */
  rb_define_const(rb_mHrrRbMountConst, "NODIRATIME",  INT2NUM(MS_NODIRATIME) );
  /* This flag can be specified in mount. */
  rb_define_const(rb_mHrrRbMountConst, "NOEXEC",      INT2NUM(MS_NOEXEC)     );
  /* This flag can be specified in mount. */
  rb_define_const(rb_mHrrRbMountConst, "NOSUID",      INT2NUM(MS_NOSUID)     );
  /* This flag can be specified in mount. */
  rb_define_const(rb_mHrrRbMountConst, "RDONLY",      INT2NUM(MS_RDONLY)     );
  /* This flag can be specified in mount. */
  rb_define_const(rb_mHrrRbMountConst, "REC",         INT2NUM(MS_REC)        );
  /* This flag can be specified in mount. */
  rb_define_const(rb_mHrrRbMountConst, "RELATIME",    INT2NUM(MS_RELATIME)   );
  /* This flag can be specified in mount. */
  rb_define_const(rb_mHrrRbMountConst, "SILENT",      INT2NUM(MS_SILENT)     );
  /* This flag can be specified in mount. */
  rb_define_const(rb_mHrrRbMountConst, "STRICTATIME", INT2NUM(MS_STRICTATIME));
  /* This flag can be specified in mount. */
  rb_define_const(rb_mHrrRbMountConst, "SYNCHRONOUS", INT2NUM(MS_SYNCHRONOUS));

  /* This flag can be specified in umount. */
  rb_define_const(rb_mHrrRbMountConst, "FORCE",    INT2NUM(MNT_FORCE)      );
  /* This flag can be specified in umount. */
  rb_define_const(rb_mHrrRbMountConst, "DETACH",   INT2NUM(MNT_DETACH)     );
  /* This flag can be specified in umount. */
  rb_define_const(rb_mHrrRbMountConst, "EXPIRE",   INT2NUM(MNT_EXPIRE)     );
  /* This flag can be specified in umount. */
  rb_define_const(rb_mHrrRbMountConst, "NOFOLLOW", INT2NUM(UMOUNT_NOFOLLOW));
}
