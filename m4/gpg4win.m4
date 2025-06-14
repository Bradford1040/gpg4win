dnl gpg4win.m4 - macros to configure gpg4win.
dnl Copyright (C) 2005, 2009 g10 Code GmbH
dnl
dnl This file is part of GPG4Win.
dnl
dnl GPG4Win is free software; you can redistribute it and/or modify
dnl it under the terms of the GNU General Public License as published by
dnl the Free Software Foundation; either version 2 of the License, or
dnl (at your option) any later version.
dnl
dnl GPG4Win is distributed in the hope that it will be useful,
dnl but WITHOUT ANY WARRANTY; without even the implied warranty of
dnl MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
dnl GNU General Public License for more details.
dnl
dnl You should have received a copy of the GNU General Public License
dnl along with this program; if not, write to the Free Software
dnl Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
dnl MA 02110-1301, USA


# GPG4WIN_DEFINE SYMBOL
# A poor man's version of AC_DEFINE_UNQUOTED for NSIS.
AC_DEFUN([GPG4WIN_DEFINE],
[
  eval $1=\"\!define $1 1\"
  AC_SUBST($1)
])


# GPG4WIN_BASH
# Gpg4Win needs bash.  This macro checks for it.
AC_DEFUN([GPG4WIN_BASH],
[
  AC_MSG_CHECKING([for Bash])
  _bash=$BASH_VERSION
  if test -z "$_bash"; then
    _bash=no
  fi
  AC_MSG_RESULT($_bash)
  if test $_bash = no; then
    AC_MSG_ERROR("this configure script requires Bash")
  fi
])


# GPG4WIN_PACKAGES

# Determines the path to the source and binary packages.  Default is
# the the "/src/packages" directory if that exists and has a file
# named BUILDTYPE, otherwise the default is the "packages" directory
# below the CWD.  The former is for the docker build system, the
# latter for the classic build system.  The path is stored in the
# shell variable gpg4win_packages.
AC_DEFUN([GPG4WIN_PACKAGES],
[
  AC_MSG_CHECKING(for packages directory)
  AS_IF([test -f /src/packages/BUILDTYPE],
        [_gpg4win_packages_default=/src/packages],
        [_gpg4win_packages_default=packages])
  AC_ARG_WITH([packages],
    AS_HELP_STRING([--with-packages=DIR],
                   [source and binary packages [[packages]]]),
    gpg4win_packages=$withval)
  AS_IF([test -z $gpg4win_packages],
        [gpg4win_packages=$_gpg4win_packages_default])
  AS_IF([test `echo $gpg4win_packages | head -c 1` != /],
        [gpg4win_packages=`pwd`/$gpg4win_packages])
  AC_SUBST(gpg4win_packages)
  AC_MSG_RESULT($gpg4win_packages)

  # Set auto-detection.  FIXME: This should accept a comma-separated
  # list of packages that will be autodetected.
  _gpg4win_auto_detection=yes
  AC_ARG_ENABLE([packages],
    AS_HELP_STRING([--enable-packages], [enable auto-detection [[yes]]]),
    _gpg4win_auto_detection=$enableval)
])


# Should be called early.
AC_DEFUN([GPG4WIN_INIT],
[
  # We call this here so its options appear before the per-package options.
  AC_REQUIRE([GPG4WIN_PACKAGES])
])


# GPG4WIN_FIND([FILE],[PATTERN],[ZIP|TAR],[DIR],[IF-FOUND],[IF-NOT-FOUND])
# Search for package file FILE in DIR.  If DIR is empty, yes or maybe,
# look in default directory.  If DIR is not maybe, abort if not found.
# The package file name is provided in gpg4win_val and the version in
# gpg4win_version.
AC_DEFUN([GPG4WIN_FIND],
[
  AC_REQUIRE([GPG4WIN_BASH])
  AC_REQUIRE([GPG4WIN_PACKAGES])

  gpg4win_val=
  gpg4win_version=

  AC_MSG_CHECKING(for package $1)
  _gpg4win_critical=no
  _gpg4win_file=
  _gpg4win_dir=$4

  # If --enable-pkg-foo was specified, make success critical.
  AS_IF([test x$_gpg4win_dir != xmaybe], [_gpg4win_critical=yes])

  # Only check if critical or auto detection is requested.
  AS_IF([test $_gpg4win_auto_detection = yes -o $_gpg4win_critical = yes],
    [AS_IF([test -z "$_gpg4win_dir" -o "$_gpg4win_dir" = yes -o "$_gpg4win_dir" = maybe],
          [_gpg4win_dir=$gpg4win_packages])

    # Install pattern.
    AS_IF([test -z "$2"], [_gpg4win_pat='$1-\([[0-9]].*\)'],
	  [_gpg4win_pat="$2"])

    # Frob pattern.  Regex party!
    [_gpg4win_glob=`echo "$_gpg4win_pat" | sed -e 's/\\\\(\(.*\)\\\\)/\1/'`]
    [_gpg4win_glob=`echo "$_gpg4win_glob" | sed -e 's/\\.\\*/*/'`]

    # Make non-matching globs expand to nothing.
    shopt -s nullglob

    _gpg4win_format=both
    AS_IF([test ! -z "$3"], _gpg4win_format="$3")

    AS_IF([test $_gpg4win_format != zip],
          [_gpg4win_file="$_gpg4win_file "`echo ${_gpg4win_dir}/${_gpg4win_glob}.tar.xz`])
    AS_IF([test $_gpg4win_format != zip],
          [_gpg4win_file="$_gpg4win_file "`echo ${_gpg4win_dir}/${_gpg4win_glob}.tar.bz2`])
    AS_IF([test $_gpg4win_format != zip],
          [_gpg4win_file="$_gpg4win_file "`echo ${_gpg4win_dir}/${_gpg4win_glob}.tbz2`])
    AS_IF([test $_gpg4win_format != zip],
          [_gpg4win_file="$_gpg4win_file "`echo ${_gpg4win_dir}/${_gpg4win_glob}.tbz`])
    AS_IF([test $_gpg4win_format != zip],
          [_gpg4win_file="$_gpg4win_file "`echo ${_gpg4win_dir}/${_gpg4win_glob}.tar.gz`])
    AS_IF([test $_gpg4win_format != zip],
          [_gpg4win_file="$_gpg4win_file "`echo ${_gpg4win_dir}/${_gpg4win_glob}.tgz`])
    AS_IF([test $_gpg4win_format != tar],
          [_gpg4win_file="$_gpg4win_file "`echo ${_gpg4win_dir}/${_gpg4win_glob}.zip`])
    AS_IF([test $_gpg4win_format != tar -a $_gpg4win_format != zip],
          [_gpg4win_file="$_gpg4win_file "`echo ${_gpg4win_dir}/${_gpg4win_glob}.exe`])
    AS_IF([test $_gpg4win_format != tar -a $_gpg4win_format != zip],
          [_gpg4win_file="$_gpg4win_file "`echo ${_gpg4win_dir}/${_gpg4win_glob}.wixlib`])
    shopt -u nullglob])

  # remove leading and trailing whitespace
  [_gpg4win_file=`echo $_gpg4win_file`]

  AS_IF([test -z "$_gpg4win_file"],
        AC_MSG_RESULT(no),
	AS_IF([test `echo $_gpg4win_file | head -c 1` != /],
              [_gpg4win_file=`pwd`/$_gpg4win_file])
        AC_MSG_RESULT($_gpg4win_file))
  AS_IF([test -z "$_gpg4win_file" -a $_gpg4win_critical = yes],
        AC_MSG_ERROR(could not find sources for $1 in $_gpg4win_dir))

  # Test for duplicate.
  _gpg4win_found=
  for _gpg4win_f in $_gpg4win_file; do
      AS_IF([test "$_gpg4win_found" = yes],
            [AC_MSG_WARN(found more than one sources for $1 in $_gpg4win_dir)
             gpg4win_dup_sources="$gpg4win_dup_sources $1";
             gpg4win_rm_candidates="$gpg4win_rm_candidates $_gpg4win_file"])
      _gpg4win_found=yes
  done

  _gpg4win_suffix_pat='\.\(tar.xz\|tar.bz2\|tbz2\|tbz\|tar.gz\|tgz\|zip\|exe\|wixlib\)'
  AS_IF([test ! -z "$_gpg4win_file"],
        [gpg4win_val="$_gpg4win_file"
         [gpg4win_version=`echo "$gpg4win_val" | sed -e "s,^.*/${_gpg4win_pat}${_gpg4win_suffix_pat}$,\1,"`]
         [$5]],
        [$6])
])


AC_DEFUN([GPG4WIN_CHECK_EXDEPS],
[
  AC_REQUIRE([GPG4WIN_CHECK_DEPS])

  AC_MSG_CHECKING([additional host build list])

  gpg4win_build_ex_list=`echo $_gpg4win_ex_deps | tsort`
  # Remove newlines.
  gpg4win_build_ex_list=`echo $gpg4win_build_ex_list`
  AC_MSG_RESULT($gpg4win_build_ex_list)
  AC_SUBST(gpg4win_build_ex_list)

  # Check each dependency.
  _gpg4win_not_found=
  _gpg4win_d=
  _gpg4win_p=
  for _gpg4win_p in $_gpg4win_ex_deps; do
    AS_IF([test -z $_gpg4win_d], [_gpg4win_d=$_gpg4win_p],
          [
            _gpg4win_found=
            for _gpg4win_i in $_gpg4win_pkgs; do
              AS_IF([test $_gpg4win_d = $_gpg4win_i],
                    _gpg4win_found=yes
                    break)
            done
            AS_IF([test -z $_gpg4win_found],
                  AC_MSG_WARN(could not find ex variant of package $_gpg4win_d required by package $_gpg4win_p)
                  _gpg4win_not_found=yes)
            _gpg4win_d=
          ])
  done
  AS_IF([test ! -z "$_gpg4win_not_found"],
        AC_MSG_ERROR([could not find some required packages]))
])

AC_DEFUN([GPG4WIN_CHECK_DEPS],
[
  AC_MSG_CHECKING(build list)
  gpg4win_build_list=`echo $_gpg4win_deps | tsort`
  # Remove newlines.
  gpg4win_build_list=`echo $gpg4win_build_list`
  AC_MSG_RESULT($gpg4win_build_list)
  AC_SUBST(gpg4win_build_list)
  # Get list of packages for NSIS.
  gpg4win_nsis_list=`echo $_gpg4win_deps | tsort | grep -v ^native-`
  gpg4win_nsis_list=`echo $gpg4win_nsis_list`
  AC_SUBST(gpg4win_nsis_list)

  # Check each dependency.
  _gpg4win_not_found=
  _gpg4win_d=
  _gpg4win_p=
  for _gpg4win_p in $_gpg4win_deps; do
    AS_IF([test -z $_gpg4win_d], [_gpg4win_d=$_gpg4win_p],
          [
            _gpg4win_found=
            for _gpg4win_i in $_gpg4win_pkgs; do
              AS_IF([test $_gpg4win_d = $_gpg4win_i],
                    _gpg4win_found=yes
                    break)
            done
            AS_IF([test -z $_gpg4win_found],
                  AC_MSG_WARN(could not find package $_gpg4win_d required by package $_gpg4win_p)
                  _gpg4win_not_found=yes)
            _gpg4win_d=
          ])
  done
  AS_IF([test ! -z "$_gpg4win_not_found"],
        AC_MSG_ERROR([could not find some required packages]))
])


AC_DEFUN([GPG4WIN_FINALIZE],
[
  AC_REQUIRE([GPG4WIN_CHECK_EXDEPS])

  _gpg4win_debug=no
  AC_ARG_ENABLE([debug],
    AS_HELP_STRING([--enable-debug], [enable debugging [[no]]]),
    _gpg4win_debug=$enableval)

  AS_IF([test "${_gpg4win_debug}" != no],
    GPG4WIN_DEFINE(GPG4WIN_DEBUG))
])


# GPG4WIN_SPKG([PKG],[DEPENDS],[IF-FOUND],[IF-NOT-FOUND])
# Set up the source package PKG.
# It is provided in gpg4win_val.
AC_DEFUN([GPG4WIN_SPKG],
[
  AC_REQUIRE([GPG4WIN_INIT])
  _gpg4win_pkg=maybe
  AC_ARG_ENABLE([pkg-$1],
    AS_HELP_STRING([--enable-pkg-$1[=DIR]],
                   [include package $1]),
    _gpg4win_pkg=$enableval)
  _gpg4win_spkg=no
  _gpg4win_version=
  AS_IF([test "$_gpg4win_pkg" != no],
        [GPG4WIN_FIND($1,,, $_gpg4win_pkg,
	 _gpg4win_spkg=$gpg4win_val
	 _gpg4win_version=$gpg4win_version)])

  # At this point, _gpg4win_spkg is no, or the actual package source file.

  # gpg4win_pkg_PKGNAME=FILENAME_OF_SOURCE
  gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]=$_gpg4win_spkg
  AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[-+],[__]))

  # gpg4win_pkg_PKGNAME_version=VERSION
  gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]_version=$_gpg4win_version
  AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]_version)

  # gpg4win_pkg_PKGNAME_deps=DEPS
  gpg4win_pkg_[]m4_translit([$1],[A-Z+-],[a-z__])[]_deps="$2"
  AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[A-Z+-],[a-z__])[]_deps)

  AS_IF([test "$_gpg4win_spkg" != no],
    _gpg4win_pkgs="$_gpg4win_pkgs $1"
    GPG4WIN_DEFINE(HAVE_PKG_[]m4_translit([$1],[a-z+-],[A-Z__]))
    # Record dependencies.  Also enter every package as node.
    _gpg4win_deps="$_gpg4win_deps $1 $1"
    AS_IF([test ! -z "$2"],
          for _gpg4win_i in $2; do
            _gpg4win_deps="$_gpg4win_deps $_gpg4win_i $1"
          done)
      [$3],
      [$4])
])


# GPG4WIN_SPKGEX([PKG],[DEPENDS],[IF-FOUND],[IF-NOT-FOUND])
# Set up the source package PKG to be additionally built
# for the host provided as additional-gpgex-host
AC_DEFUN([GPG4WIN_SPKGEX],
[
  AC_REQUIRE([GPG4WIN_INIT])
  _gpg4win_pkg=maybe
  AC_ARG_ENABLE([pkg-$1],
    AS_HELP_STRING([--enable-pkg-$1[=DIR]],
                   [include package $1]),
    _gpg4win_pkg=$enableval)
  _gpg4win_spkg=no
  _gpg4win_version=
  AS_IF([test "$_gpg4win_pkg" != no],
        [GPG4WIN_FIND($1,,, $_gpg4win_pkg,
	 _gpg4win_spkg=$gpg4win_val
	 _gpg4win_version=$gpg4win_version)])
  # At this point, _gpg4win_spkg is no, or the actual package source file.

  # gpg4win_pkg_PKGNAME=FILENAME_OF_SOURCE
  gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]=$_gpg4win_spkg
  AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[-+],[__]))

  # gpg4win_pkg_PKGNAME_version=VERSION
  gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]_version=$_gpg4win_version
  AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]_version)

  AS_IF([test ! -z "$GPGEX_ADD_HOST"],

    # gpg4win_pkg_PKGNAME_deps=DEPS
    gpg4win_pkg_[]m4_translit([$1],[A-Z+-],[a-z__])[]_ex_deps="$2"
    AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[A-Z+-],[a-z__])[]_ex_deps)

    AS_IF([test "$_gpg4win_spkg" != no],
      gpg4win_ex_pkgs="$gpg4win_ex_pkgs $1"

      GPG4WIN_DEFINE(HAVE_PKG_[]m4_translit([$1],[a-z+-],[A-Z__])_EX)
      # Record dependencies.  Also enter every package as node.
      _gpg4win_ex_deps="$_gpg4win_ex_deps $1 $1"
      AS_IF([test ! -z "$2"],
            for _gpg4win_i in $2; do
              _gpg4win_ex_deps="$_gpg4win_ex_deps $_gpg4win_i $1"
            done)
    )
  )
])

# GPG4WIN_KDEPKG([PKG],[DEPENDS],[IF-FOUND],[IF-NOT-FOUND])
# Set up the source package PKG to be additionally built
# for the host provided as additional-gpgex-host
AC_DEFUN([GPG4WIN_KDEPKG],
[
  AC_REQUIRE([GPG4WIN_INIT])
  _gpg4win_pkg=maybe
  AC_ARG_ENABLE([pkg-$1],
    AS_HELP_STRING([--enable-pkg-$1[=DIR]],
                   [include package $1]),
    _gpg4win_pkg=$enableval)
  _gpg4win_kdepkg=no
  _gpg4win_version=
  AS_IF([test "$_gpg4win_pkg" != no],
        [GPG4WIN_FIND($1,,, $_gpg4win_pkg,
        _gpg4win_kdepkg=$gpg4win_val
        _gpg4win_version=$gpg4win_version)])

  # gpg4win_pkg_PKGNAME=FILENAME_OF_SOURCE
  gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]=$_gpg4win_kdepkg
  AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[-+],[__]))

  # gpg4win_pkg_PKGNAME_version=VERSION
  gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]_version=$_gpg4win_version
  AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]_version)

  # gpg4win_pkg_PKGNAME_deps=DEPS
  gpg4win_pkg_[]m4_translit([$1],[A-Z+-],[a-z__])[]_deps="$2"
  AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[A-Z+-],[a-z__])[]_deps)

  AS_IF([test "$_gpg4win_kdepkg" != no],
    _gpg4win_pkgs="$_gpg4win_pkgs $1"
    GPG4WIN_DEFINE(HAVE_PKG_[]m4_translit([$1],[a-z+-],[A-Z__]))
    # Record dependencies.  Also enter every package as node.
    _gpg4win_deps="$_gpg4win_deps $1 $1"
    AS_IF([test ! -z "$2"],
          for _gpg4win_i in $2; do
            _gpg4win_deps="$_gpg4win_deps $_gpg4win_i $1"
          done)
      [$3],
      [$4])
])

# GPG4WIN_CMKPKGEX([PKG],[DEPENDS],[IF-FOUND],[IF-NOT-FOUND])
# Set up the CMake package PKG to be built additionally
# for the host provided as additional-gpgex-host
AC_DEFUN([GPG4WIN_CMKPKGEX],
[
  AC_REQUIRE([GPG4WIN_INIT])
  _gpg4win_pkg=maybe
  AC_ARG_ENABLE([pkg-$1],
    AS_HELP_STRING([--enable-pkg-$1[=DIR]],
                   [include package $1]),
    _gpg4win_pkg=$enableval)
  _gpg4win_cmkpkg=no
  _gpg4win_version=
  AS_IF([test "$_gpg4win_pkg" != no],
        [GPG4WIN_FIND($1,,, $_gpg4win_pkg,
        _gpg4win_cmkpkg=$gpg4win_val
        _gpg4win_version=$gpg4win_version)])

  # gpg4win_pkg_PKGNAME=FILENAME_OF_SOURCE
  gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]=$_gpg4win_cmkpkg
  AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[-+],[__]))

  # gpg4win_pkg_PKGNAME_version=VERSION
  gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]_version=$_gpg4win_version
  AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]_version)

  AS_IF([test ! -z "$GPGEX_ADD_HOST"],

    # gpg4win_pkg_PKGNAME_deps=DEPS
    gpg4win_pkg_[]m4_translit([$1],[A-Z+-],[a-z__])[]_ex_deps="$2"
    AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[A-Z+-],[a-z__])[]_ex_deps)

    _gpg4win_ex_pkgs="$_gpg4win_ex_pkgs $1"

    GPG4WIN_DEFINE(HAVE_PKG_[]m4_translit([$1],[a-z+-],[A-Z__]))
    # Record dependencies.  Also enter every package as node.
    _gpg4win_ex_deps="$_gpg4win_ex_deps $1 $1"
    AS_IF([test ! -z "$2"],
          for _gpg4win_i in $2; do
            _gpg4win_ex_deps="$_gpg4win_ex_deps $_gpg4win_i $1"
          done)
  )
])

# GPG4WIN_NATIVEPKG([PKG],[DEPENDS],[IF-FOUND],[IF-NOT-FOUND])
# Set up the source package PKG to be additionally built
# natively to provide additional tools on the build system.
AC_DEFUN([GPG4WIN_NATIVEPKG],
[
  AC_REQUIRE([GPG4WIN_INIT])
  _gpg4win_pkg=maybe
  AC_ARG_ENABLE([pkg-$1],
    AS_HELP_STRING([--enable-pkg-$1[=DIR]],
                   [include package $1]),
    _gpg4win_pkg=$enableval)
  _gpg4win_spkg=no
  _gpg4win_version=
  AS_IF([test "$_gpg4win_pkg" != no],
        [GPG4WIN_FIND($1,,, $_gpg4win_pkg,
	 _gpg4win_spkg=$gpg4win_val
	 _gpg4win_version=$gpg4win_version)])
  # At this point, _gpg4win_spkg is no, or the actual package source file.

  # gpg4win_pkg_PKGNAME=FILENAME_OF_SOURCE
  gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]=$_gpg4win_spkg
  AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[-+],[__]))

  # gpg4win_pkg_PKGNAME_version=VERSION
  gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]_version=$_gpg4win_version
  AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]_version)

  # gpg4win_pkg_PKGNAME_deps=DEPS
  gpg4win_pkg_[]m4_translit([$1],[A-Z+-],[a-z__])[]_native_deps="$2"
  AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[A-Z+-],[a-z__])[]_native_deps)

  GPG4WIN_DEFINE(HAVE_PKG_[]m4_translit([$1],[a-z+-],[A-Z__])_NATIVE)

  _gpg4win_pkgs="$_gpg4win_pkgs native-$1"

  # Record dependencies.  Also enter every package as node.
  _gpg4win_deps="$_gpg4win_deps native-$1 native-$1"
  AS_IF([test ! -z "$2"],
        for _gpg4win_i in $2; do
          _gpg4win_deps="$_gpg4win_deps native-$_gpg4win_i native-$1"
        done)
])

# GPG4WIN_BPKG_GNUWIN32([PKG],[DEPENDS],[IF-FOUND],[IF-NOT-FOUND])
# Set up the gnuwin32 package PKG.
# It is provided in gpg4win_val.
AC_DEFUN([GPG4WIN_BPKG_GNUWIN32],
[
  AC_REQUIRE([GPG4WIN_INIT])
  _gpg4win_pkg=maybe
  AC_ARG_ENABLE([pkg-$1],
    AS_HELP_STRING([--enable-pkg-$1[=DIR]],
                   [include package $1]),
    _gpg4win_pkg=$enableval)
  _gpg4win_bpkg=no
  _gpg4win_version=
  AS_IF([test "$_gpg4win_pkg" != no],
        [GPG4WIN_FIND($1-bin, [$1-\(.*\)-bin],,
         $_gpg4win_pkg,
         _gpg4win_bpkg=$gpg4win_val
	 _gpg4win_version=$gpg4win_version)])

  # At this point, _gpg4win_bpkg is no, or the actual package source file.

  # gpg4win_pkg_PKGNAME=FILENAME_OF_BINARY
  gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]=$_gpg4win_bpkg
  AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[-+],[__]))

  # gpg4win_pkg_PKGNAME_version=VERSION
  gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]_version=$_gpg4win_version
  AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]_version)

  # gpg4win_pkg_PKGNAME_deps=DEPS
  gpg4win_pkg_[]m4_translit([$1],[A-Z+-],[a-z__])[]_deps="$2"
  AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[A-Z+-],[a-z__])[]_deps)

  AS_IF([test "$_gpg4win_bpkg" != "no" ],
    GPG4WIN_FIND($1-lib, [$1-\(.*\)-lib],,
                 $_gpg4win_pkg, _gpg4win_bpkg=$gpg4win_val,
       AC_MSG_ERROR(can not find development package for package $1))
    # gpg4win_pkg_PKGNAME_dev=FILENAME_OF_BINARY_DEVEL
    gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]_dev=$_gpg4win_bpkg
    AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]_dev)

    GPG4WIN_FIND($1-src, [$1-\(.*\)-src],,
                 $_gpg4win_pkg, _gpg4win_bpkg=$gpg4win_val,
       AC_MSG_ERROR(can not find sources for package $1))
    # gpg4win_pkg_PKGNAME_src=FILENAME_OF_SOURCE
    gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]_src=$_gpg4win_bpkg
    AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]_src)

    # FIXME: Add a version consistency check here.  All three packages
    # must match!

    GPG4WIN_DEFINE(HAVE_PKG_[]m4_translit([$1],[a-z+-],[A-Z__]))

    _gpg4win_pkgs="$_gpg4win_pkgs $1"
    # Record dependencies.  Also enter every package as node.
    _gpg4win_deps="$_gpg4win_deps $1 $1"
    AS_IF([test ! -z "$2"],
          for _gpg4win_i in $2; do
	    _gpg4win_deps="$_gpg4win_deps $_gpg4win_i $1"
          done)
          [$3],
          [$4])
])

# GPG4WIN_BPKG_GNUWIN32_LIB([PKG],[DEPENDS],[IF-FOUND],[IF-NOT-FOUND])
# Set up the gnuwin32 package PKG.  This is a static only library version.
# It is provided in gpg4win_val.
AC_DEFUN([GPG4WIN_BPKG_GNUWIN32_LIB],
[
  AC_REQUIRE([GPG4WIN_INIT])
  _gpg4win_pkg=maybe
  AC_ARG_ENABLE([pkg-$1],
    AS_HELP_STRING([--enable-pkg-$1[=DIR]],
                   [include package $1]),
    _gpg4win_pkg=$enableval)
  _gpg4win_bpkg=no
  _gpg4win_version=
  AS_IF([test "$_gpg4win_pkg" != no],
        [GPG4WIN_FIND($1-lib, [$1-\(.*\)-lib],,
         $_gpg4win_pkg,
         _gpg4win_bpkg=$gpg4win_val
	 _gpg4win_version=$gpg4win_version)])

  # At this point, _gpg4win_bpkg is no, or the actual package source file.

  # gpg4win_pkg_PKGNAME=FILENAME_OF_BINARY
  gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]=$_gpg4win_bpkg
  AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[-+],[__]))

  # gpg4win_pkg_PKGNAME_version=VERSION
  gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]_version=$_gpg4win_version
  AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]_version)

  AS_IF([test "$_gpg4win_bpkg" != no],
    GPG4WIN_FIND($1-src, [$1-\(.*\)-src],,
                 $_gpg4win_pkg, _gpg4win_bpkg=$gpg4win_val,
       AC_MSG_ERROR(can not find sources for package $1))
    # gpg4win_pkg_PKGNAME_src=FILENAME_OF_SOURCE
    gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]_src=$_gpg4win_bpkg
    AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]_src)

    # FIXME: Add a version consistency check here.  All two packages
    # must match!

    GPG4WIN_DEFINE(HAVE_PKG_[]m4_translit([$1],[a-z+-],[A-Z__]))

    _gpg4win_pkgs="$_gpg4win_pkgs $1"
    # Record dependencies.  Also enter every package as node.
    _gpg4win_deps="$_gpg4win_deps $1 $1"
    AS_IF([test ! -z "$2"],
          for _gpg4win_i in $2; do
	    _gpg4win_deps="$_gpg4win_deps $_gpg4win_i $1"
          done)
          [$3],
          [$4])
])


# GPG4WIN_BPKG_GTK([PKG],[DEPENDS],[IF-FOUND],[IF-NOT-FOUND])
# Set up the Gtk binary package PKG.
# It is provided in gpg4win_val.
AC_DEFUN([GPG4WIN_BPKG_GTK],
[
  AC_REQUIRE([GPG4WIN_INIT])
  _gpg4win_pkg=maybe
  AC_ARG_ENABLE([pkg-$1],
    AS_HELP_STRING([--enable-pkg-$1[=DIR]],
                   [include package $1]),
    _gpg4win_pkg=$enableval)
  _gpg4win_bpkg=no
  _gpg4win_version=
  AS_IF([test "$_gpg4win_pkg" != no],
        [GPG4WIN_FIND($1,,zip, $_gpg4win_pkg,
         _gpg4win_bpkg=$gpg4win_val
	 _gpg4win_version=$gpg4win_version)])

  # At this point, _gpg4win_bpkg is no, or the actual package source file.

  # gpg4win_pkg_PKGNAME=FILENAME_OF_BINARY
  gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]=$_gpg4win_bpkg
  AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[-+],[__]))

  # gpg4win_pkg_PKGNAME_version=VERSION
  gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]_version=$_gpg4win_version
  AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]_version)

  # gpg4win_pkg_PKGNAME_deps=DEPS
  gpg4win_pkg_[]m4_translit([$1],[A-Z+-],[a-z__])[]_deps="$2"
  AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[A-Z+-],[a-z__])[]_deps)

  AS_IF([test "$_gpg4win_bpkg" != no],
    [GPG4WIN_FIND($1,,tar, $_gpg4win_pkg, _gpg4win_bpkg=$gpg4win_val,
       AC_MSG_ERROR(can not find sources for package $1))]
    # gpg4win_pkg_PKGNAME_src=FILENAME_OF_SOURCE
    gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]_src=$_gpg4win_bpkg
    AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]_src)

    # FIXME: Add a version consistency check here.  All three packages
    # must match!

    GPG4WIN_DEFINE(HAVE_PKG_[]m4_translit([$1],[a-z+-],[A-Z__]))

    _gpg4win_pkgs="$_gpg4win_pkgs $1"
    # Record dependencies.  Also enter every package as node.
    _gpg4win_deps="$_gpg4win_deps $1 $1"
    AS_IF([test ! -z "$2"],
          for _gpg4win_i in $2; do
	    _gpg4win_deps="$_gpg4win_deps $_gpg4win_i $1"
          done)
          [$3],
          [$4])
])


# GPG4WIN_BPKG_GTK_DEV([PKG],[DEPENDS],[IF-FOUND],[IF-NOT-FOUND])
# Set up the Gtk library package PKG.
# It is provided in gpg4win_val.
AC_DEFUN([GPG4WIN_BPKG_GTK_DEV],
[
  AC_REQUIRE([GPG4WIN_INIT])
  _gpg4win_pkg=maybe
  AC_ARG_ENABLE([pkg-$1],
    AS_HELP_STRING([--enable-pkg-$1[=DIR]],
                   [include package $1]),
    _gpg4win_pkg=$enableval)
  _gpg4win_bpkg=no
  _gpg4win_version=
  AS_IF([test "$_gpg4win_pkg" != no],
        [GPG4WIN_FIND($1,,zip, $_gpg4win_pkg,
         _gpg4win_bpkg=$gpg4win_val
	 _gpg4win_version=$gpg4win_version)])

  # At this point, _gpg4win_bpkg is no, or the actual package source file.

  # gpg4win_pkg_PKGNAME=FILENAME_OF_BINARY
  gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]=$_gpg4win_bpkg
  AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[-+],[__]))

  # gpg4win_pkg_PKGNAME_version=VERSION
  gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]_version=$_gpg4win_version
  AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]_version)

  # gpg4win_pkg_PKGNAME_deps=DEPS
  gpg4win_pkg_[]m4_translit([$1],[A-Z+-],[a-z__])[]_deps="$2"
  AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[A-Z+-],[a-z__])[]_deps)

  AS_IF([test "$_gpg4win_bpkg" != no],
    [GPG4WIN_FIND($1-dev,,, $_gpg4win_pkg, _gpg4win_bpkg=$gpg4win_val,
       AC_MSG_ERROR(can not find development package for package $1))]
    # gpg4win_pkg_PKGNAME_dev=FILENAME_OF_BINARY_DEVEL
    gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]_dev=$_gpg4win_bpkg
    AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]_dev)

    [GPG4WIN_FIND($1,,tar, $_gpg4win_pkg, _gpg4win_bpkg=$gpg4win_val,
       AC_MSG_ERROR(can not find sources for package $1))]
    # gpg4win_pkg_PKGNAME_src=FILENAME_OF_SOURCE
    gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]_src=$_gpg4win_bpkg
    AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]_src)

    # FIXME: Add a version consistency check here.  All three packages
    # must match!

    GPG4WIN_DEFINE(HAVE_PKG_[]m4_translit([$1],[a-z+-],[A-Z__]))

    _gpg4win_pkgs="$_gpg4win_pkgs $1"
    # Record dependencies.  Also enter every package as node.
    _gpg4win_deps="$_gpg4win_deps $1 $1"
    AS_IF([test ! -z "$2"],
          for _gpg4win_i in $2; do
	    _gpg4win_deps="$_gpg4win_deps $_gpg4win_i $1"
          done)
          [$3],
          [$4])
])


# GPG4WIN_BPKG_GNU([PKG],[DEPENDS],[IF-FOUND],[IF-NOT-FOUND])
# Set up the source package PKG.
# It is provided in gpg4win_val.
AC_DEFUN([GPG4WIN_BPKG_GNU],
[
  AC_REQUIRE([GPG4WIN_INIT])
  _gpg4win_pkg=maybe
  AC_ARG_ENABLE([pkg-$1],
    AS_HELP_STRING([--enable-pkg-$1[=DIR]],
                   [include package $1]),
    _gpg4win_pkg=$enableval)
  _gpg4win_bpkg=no
  _gpg4win_version=

  AS_IF([test "$_gpg4win_pkg" != no],
        [
          # For some shameful reason, the gettext package is actually called
          # gettext-runtime!
          AS_IF([test $1 = gettext],
	        [GPG4WIN_FIND($1-runtime,,zip, $_gpg4win_pkg,
 		             _gpg4win_bpkg=$gpg4win_val
		 	     _gpg4win_version=$gpg4win_version)],
		[GPG4WIN_FIND($1,,zip, $_gpg4win_pkg,
 		             _gpg4win_bpkg=$gpg4win_val
		 	     _gpg4win_version=$gpg4win_version)])
	])

  # At this point, _gpg4win_bpkg is no, or the actual package source file.

  # gpg4win_pkg_PKGNAME=FILENAME_OF_BINARY
  gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]=$_gpg4win_bpkg
  AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[-+],[__]))

  # gpg4win_pkg_PKGNAME_version=VERSION
  gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]_version=$_gpg4win_version
  AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]_version)

  # gpg4win_pkg_PKGNAME_deps=DEPS
  gpg4win_pkg_[]m4_translit([$1],[A-Z+-],[a-z__])[]_deps="$2"
  AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[A-Z+-],[a-z__])[]_deps)

  AS_IF([test "$_gpg4win_bpkg" != no],
    [GPG4WIN_FIND($1,,tar, $_gpg4win_pkg, _gpg4win_bpkg=$gpg4win_val,
       AC_MSG_ERROR(can not find sources for package $1))]
    # gpg4win_pkg_PKGNAME_src=FILENAME_OF_SOURCE
    gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]_src=$_gpg4win_bpkg
    AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[-+],[__])[]_src)

    # FIXME: Add a version consistency check here.  All two packages
    # must match!

    GPG4WIN_DEFINE(HAVE_PKG_[]m4_translit([$1],[a-z+-],[A-Z__]))

    _gpg4win_pkgs="$_gpg4win_pkgs $1"
    # Record dependencies.  Also enter every package as node.
    _gpg4win_deps="$_gpg4win_deps $1 $1"
    AS_IF([test ! -z "$2"],
          for _gpg4win_i in $2; do
	    _gpg4win_deps="$_gpg4win_deps $_gpg4win_i $1"
          done)
          [$3],
          [$4])
])

# GPG4WIN_BPKG_MSISRC([PKG],[DEPENDS],[IF-FOUND],[IF-NOT-FOUND])
# Set up package PKG which is expected to be delivered as two ZIP files
# with a "-(src|source)" and a "-(bin|noinstaller)" suffix.
AC_DEFUN([GPG4WIN_BPKG_MSISRC],
[
  AC_REQUIRE([GPG4WIN_INIT])
  _gpg4win_pkg=maybe
  AC_ARG_ENABLE([pkg-$1],
    AS_HELP_STRING([--enable-pkg-$1[=DIR]],
                   [include package $1]),
    _gpg4win_pkg=$enableval)
  _gpg4win_bpkg=no
  _gpg4win_version=
  AS_IF([test "$_gpg4win_pkg" != no],
        [GPG4WIN_FIND($1-bin, [$1-\(.*\)-bin],,
         $_gpg4win_pkg,
         _gpg4win_bpkg=$gpg4win_val
	 _gpg4win_version=$gpg4win_version)])
  AS_IF([test "$_gpg4win_pkg" != no -a "$_gpg4win_bpkg" = no],
        [GPG4WIN_FIND($1-noinstaller, [$1-\(.*\)-noinstaller],,
         $_gpg4win_pkg,
         _gpg4win_bpkg=$gpg4win_val
	 _gpg4win_version=$gpg4win_version)])

  # At this point, _gpg4win_bpkg is no, or the actual package binary file.

  # gpg4win_pkg_PKGNAME=FILENAME_OF_BINARY
  gpg4win_pkg_[]m4_translit([$1],[A-Z+-],[a-z__])[]=$_gpg4win_bpkg
  AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[A-Z+-],[a-z__]))

  # gpg4win_pkg_PKGNAME_version=VERSION
  gpg4win_pkg_[]m4_translit([$1],[A-Z+-],[a-z__])[]_version=$_gpg4win_version
  AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[A-Z+-],[a-z__])[]_version)

  # gpg4win_pkg_PKGNAME_deps=DEPS
  gpg4win_pkg_[]m4_translit([$1],[A-Z+-],[a-z__])[]_deps="$2"
  AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[A-Z+-],[a-z__])[]_deps)

  AS_IF([test "$_gpg4win_bpkg" != no],
    tmp_binsrc=yes
    GPG4WIN_FIND($1-src, [$1-\(.*\)-src],,
                 $_gpg4win_pkg, _gpg4win_bpkg=$gpg4win_val, tmp_binsrc=no)
    if test $tmp_binsrc = no ; then
       GPG4WIN_FIND($1-source, [$1-\(.*\)-source],,
                    $_gpg4win_pkg, _gpg4win_bpkg=$gpg4win_val,
                    AC_MSG_ERROR(can not find sources for package $1))
    fi
    # gpg4win_pkg_PKGNAME_src=FILENAME_OF_SOURCE
    gpg4win_pkg_[]m4_translit([$1],[A-Z+-],[a-z__])[]_src=$_gpg4win_bpkg
    AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[A-Z+-],[a-z__])[]_src)
    GPG4WIN_DEFINE(HAVE_PKG_[]m4_translit([$1],[a-z+-],[A-Z__]))
    )
])


# GPG4WIN_BPKG_BINSRC([PKG],[DEPENDS],[IF-FOUND],[IF-NOT-FOUND])
# Set up package PKG which is expected to be delivered as two ZIP files
# with a "-(src|source)" and a "-(bin|noinstaller)" suffix.
AC_DEFUN([GPG4WIN_BPKG_BINSRC],
[
  AC_REQUIRE([GPG4WIN_INIT])
  _gpg4win_pkg=maybe
  AC_ARG_ENABLE([pkg-$1],
    AS_HELP_STRING([--enable-pkg-$1[=DIR]],
                   [include package $1]),
    _gpg4win_pkg=$enableval)
  _gpg4win_bpkg=no
  _gpg4win_version=
  AS_IF([test "$_gpg4win_pkg" != no],
        [GPG4WIN_FIND($1-bin, [$1-\(.*\)-bin],,
         $_gpg4win_pkg,
         _gpg4win_bpkg=$gpg4win_val
	 _gpg4win_version=$gpg4win_version)])
  AS_IF([test "$_gpg4win_pkg" != no -a "$_gpg4win_bpkg" = no],
        [GPG4WIN_FIND($1-noinstaller, [$1-\(.*\)-noinstaller],,
         $_gpg4win_pkg,
         _gpg4win_bpkg=$gpg4win_val
	 _gpg4win_version=$gpg4win_version)])

  # At this point, _gpg4win_bpkg is no, or the actual package binary file.

  # gpg4win_pkg_PKGNAME=FILENAME_OF_BINARY
  gpg4win_pkg_[]m4_translit([$1],[A-Z+-],[a-z__])[]=$_gpg4win_bpkg
  AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[A-Z+-],[a-z__]))

  # gpg4win_pkg_PKGNAME_version=VERSION
  gpg4win_pkg_[]m4_translit([$1],[A-Z+-],[a-z__])[]_version=$_gpg4win_version
  AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[A-Z+-],[a-z__])[]_version)

  # gpg4win_pkg_PKGNAME_deps=DEPS
  gpg4win_pkg_[]m4_translit([$1],[A-Z+-],[a-z__])[]_deps="$2"
  AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[A-Z+-],[a-z__])[]_deps)

  AS_IF([test "$_gpg4win_bpkg" != no],
    tmp_binsrc=yes
    GPG4WIN_FIND($1-src, [$1-\(.*\)-src],,
                 $_gpg4win_pkg, _gpg4win_bpkg=$gpg4win_val, tmp_binsrc=no)
    if test $tmp_binsrc = no ; then
       GPG4WIN_FIND($1-source, [$1-\(.*\)-source],,
                    $_gpg4win_pkg, _gpg4win_bpkg=$gpg4win_val,
                    AC_MSG_ERROR(can not find sources for package $1))
    fi
    # gpg4win_pkg_PKGNAME_src=FILENAME_OF_SOURCE
    gpg4win_pkg_[]m4_translit([$1],[A-Z+-],[a-z__])[]_src=$_gpg4win_bpkg
    AC_SUBST(gpg4win_pkg_[]m4_translit([$1],[A-Z+-],[a-z__])[]_src)

    # FIXME: Add a version consistency check here.  Both packages
    # must match!

    GPG4WIN_DEFINE(HAVE_PKG_[]m4_translit([$1],[a-z+-],[A-Z__]))

    _gpg4win_pkgs="$_gpg4win_pkgs []m4_translit([$1],[A-Z],[a-z])"
    # Record dependencies.  Also enter every package as node.
    _gpg4win_deps="$_gpg4win_deps []m4_translit([$1],[A-Z],[a-z]) []m4_translit([$1],[A-Z],[a-z])"
    AS_IF([test ! -z "$2"],
          for _gpg4win_i in $2; do
	    _gpg4win_deps="$_gpg4win_deps $_gpg4win_i []m4_translit([$1],[A-Z],[a-z])"
          done)
          [$3],
          [$4])
])


# Add a runtime library.  Argument 1 should be the dll
# name without the .dll suffix.  If argument 2 is "REQUIRED" the
# function fails if the DLL was not found.  On success an
# AC_SUBST(gpg4win_rtlib_$(1)) is done.
#
AC_DEFUN([GPG4WIN_RUNTIME_LIBRARY],
[
    dll_path="no"
    AC_ARG_WITH([$1],
    AS_HELP_STRING([--with-$1-dll[=FILE]],
                   [include FILE as runtime dependency for the installer.]),
                   [dll_path=$withval])

    if test "$dll_path" = "no"; then
        changequote(,)
        gcc_major_minor=$($CC --version \
                          | awk 'NR==1 {split($NF,a,"."); print a[1] "." a[2]}')
        gcc_major_minor_alt=$($CC --version | cut -d " " -f 3 \
                             | awk 'NR==1 {split($NF,a,"."); print a[1] "." a[2]}')
        gcc_major=$($CC -dumpversion)
        changequote([,])
        guesses="/usr/lib/gcc/$host/$gcc_major_minor/$1.dll
                 /usr/lib/gcc/$host/${gcc_major}/$1.dll
                 /usr/$host/bin/$1.dll
                 /usr/$host/lib/$1.dll
                 /usr/lib/gcc/$host/${gcc_major_minor}-posix/$1.dll
                 /usr/lib/gcc/$host/${gcc_major_minor_alt}-posix/$1.dll
                 /usr/lib/gcc/$host/${gcc_major_minor_alt}/$1.dll
                 /usr/$host/sys-root/mingw/bin/$1.dll"

        for file in $guesses; do
            if test -r "$file"; then
                dll_path="$file"
                break
            fi
        done
    fi

    if test "$2" = "REQUIRED" -a "$dll_path" = "no"; then
        AC_MSG_ERROR(can not find the runtime library $1.dll in the default locations.
                     Use the --with-$1-dll option to set the path directly.
        )
    elif test "$dll_path" = no; then
        AC_MSG_NOTICE(Using dummy for $1.dll)
    else
        AC_MSG_NOTICE(Using $dll_path to provide $1.dll)
    fi
    gpg4win_rtlib_[]m4_translit([$1],[-+],[__])[]="$dll_path"
    AC_SUBST(gpg4win_rtlib_[]m4_translit([$1],[-+],[__]))
])

AC_DEFUN([GPG4WIN_RUNTIME_LIBRARY_EX],
[
    dll_path="no"
    AC_ARG_WITH([$1],
    AS_HELP_STRING([--with-ex-$1-dll[=FILE]],
                   [include FILE as runtime dependency for the installer.]),
                   [dll_path=$withval])

    if test "$dll_path" = "no"; then
        changequote(,)
        gcc_major_minor=$($CC --version \
                          | awk 'NR==1 {split($NF,a,"."); print a[1] "." a[2]}')
        gcc_major_minor_alt=$($CC --version | cut -d " " -f 3 \
                             | awk 'NR==1 {split($NF,a,"."); print a[1] "." a[2]}')
        changequote([,])
        guesses="/usr/lib/gcc/$gpgex_host/$gcc_major_minor/$1.dll
                 /usr/$gpgex_host/bin/$1.dll
                 /usr/$gpgex_host/lib/$1.dll
                 /usr/lib/gcc/$gpgex_host/${gcc_major_minor}-posix/$1.dll
                 /usr/lib/gcc/$gpgex_host/${gcc_major_minor_alt}-posix/$1.dll
                 /usr/lib/gcc/$gpgex_host/${gcc_major_minor_alt}/$1.dll
                 /usr/$gpgex_host/sys-root/mingw/bin/$1.dll
                 /usr/lib/gcc/$gpgex_host/10-posix/$1.dll"

        for file in $guesses; do
            if test -r "$file"; then
                dll_path="$file"
                break
            fi
        done
    fi

    if test "$2" = "REQUIRED" -a "$dll_path" = "no"; then
        AC_MSG_ERROR(can not find the ex runtime library $1.dll in the default locations.
                     Use the --with-ex-$1-dll option to set the path directly.
        )
    elif test "$dll_path" = no; then
        AC_MSG_NOTICE(Using dummy for $1.dll for $gpgex_host)
    else
        AC_MSG_NOTICE(Using $dll_path to provide $1.dll for $gpgex_host)
    fi
    gpg4win_rtlib_ex_[]m4_translit([$1],[-+],[__])[]="$dll_path"
    AC_SUBST(gpg4win_rtlib_ex_[]m4_translit([$1],[-+],[__]))
])


# GPG4WIN_BUILD_RELEASE(NAME,DEFAULT)
# Add a --enable-NAME option to configure and set the shell variable
# build_NAME either to "yes" or "no".  DEFAULT must either be "yes" or "no"
# and decides on the default value for build_NAME and whether --enable-NAME
# or --disable-NAME is shown with ./configure --help
AC_DEFUN([GPG4WIN_BUILD_RELEASE],
  [m4_define([my_build], [m4_bpatsubst(build_$1, [[^a-zA-Z0-9_]], [_])])
   my_build=$2
   m4_if([$2],[yes],[
      AC_ARG_ENABLE([$1], AS_HELP_STRING([--disable-$1],
                                         [do not build the $1 release]),
                           my_build=$enableval, my_build=$2)
    ],[
      AC_ARG_ENABLE([$1], AS_HELP_STRING([--enable-$1],
                                         [build the $1 release]),
                           my_build=$enableval, my_build=$2)
    ])
   case "$my_build" in
         no|yes)
           ;;
         *)
           AC_MSG_ERROR([only yes or no allowed for feature --enable-$1])
           ;;
   esac
   m4_undefine([my_build])
  ])
