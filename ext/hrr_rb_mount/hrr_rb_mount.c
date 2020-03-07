#include "hrr_rb_mount.h"

VALUE rb_mHrrRbMount;

void
Init_hrr_rb_mount(void)
{
  rb_mHrrRbMount = rb_define_module("HrrRbMount");
}
