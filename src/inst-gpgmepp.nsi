# inst-gpgmepp.nsi - Installer snippet for gpgmepp. -*- coding: latin-1; -*-
# Copyright (C) 2005, 2007, 2008, 2025 g10 Code GmbH
#
# This file is part of GPG4Win.
#
# GPG4Win is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# GPG4Win is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA


!ifdef prefix
!undef prefix
!endif
!define prefix ${ipdir}/gpgmepp-${gpg4win_pkg_gpgmepp_version}
!ifdef exprefix
!undef exprefix
!endif
!define exprefix ${exipdir}/gpgmepp-${gpg4win_pkg_gpgmepp_version}

!ifdef DEBUG
Section "gpgmepp" SEC_gpgmepp
!else
Section "-gpgmepp" SEC_gpgmepp
!endif
  SetOutPath "$INSTDIR"
!ifdef SOURCES
  File "${gpg4win_pkg_gpgmepp}"
!else
  SetOutPath "$INSTDIR\bin"
  ClearErrors
  SetOverwrite try
  File "${prefix}/bin/libgpgmepp-6.dll"

${If} ${RunningX64}

  # Install the 64 bit version of the dll.
  SetOutPath "$INSTDIR\bin_64"
  ClearErrors
  SetOverwrite try
  File ${exprefix}/bin/libgpgmepp-6.dll
  SetOverwrite lastused
  ifErrors 0 +3
      File /oname=libgpgmepp-6.dll.tmp "${exprefix}/bin/libgpgmepp-6.dll"
      Rename /REBOOTOK libgpgmepp-6.dll.tmp libgpgmepp-6.dll

${EndIf}

!endif
SectionEnd
