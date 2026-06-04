# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.61])
AC_INIT([dng], [1.7.1], [none@example.com])
AM_INIT_AUTOMAKE([foreign])

# Checks for programs.
AC_PROG_CXX

# Checks for libraries.
AC_PROG_RANLIB

# Checks for header files.

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.

AC_CANONICAL_HOST
case "${host_os}" in
  *linux*)
    AC_DEFINE(qLinux)
    AC_DEFINE(UNIX_ENV)
    AC_DEFINE(XMP_UNIXBuild)
    ;;
  *cygwin*|*mingw*)
    AC_DEFINE(qWinOS)
    ;;
  *darwin*)
    AC_DEFINE(qMacOS)
    ;;
  *android*)
    AC_DEFINE(qAndroid)
    ;;
  *)
    AC_MSG_ERROR(["$host_os not supported"])
    ;;
esac

AC_CONFIG_FILES([Makefile])
AC_OUTPUT
