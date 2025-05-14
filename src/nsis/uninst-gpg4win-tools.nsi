# Copyright (C) 2018 Intevation GmbH
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
!define prefix ${ipdir}/gpg4win_tools-${gpg4win_pkg_gpg4win_tools_version}

; Uninstaller section.
Section "-un.gpg4win_tools"
!ifdef SOURCES
  Push "${gpg4win_pkg_gpg4win_tools}"
  Call un.SourceDelete
!endif
  Delete /REBOOTOK "$INSTDIR\bin\resolver.exe"
  Delete /REBOOTOK "$INSTDIR\bin\overlayer.exe"
  Delete /REBOOTOK "$INSTDIR\bin\gpgolconfig.exe"
  Delete /REBOOTOK "$INSTDIR\bin\gpgolkeyadder.exe"
  RMDir "$INSTDIR\bin"
SectionEnd
