# Copyright (C) 2015 Intevation GmbH
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
!define prefix ${ipdir}/kconfigwidgets-${gpg4win_pkg_kconfigwidgets_version}

!ifdef DEBUG
Section "kconfigwidgets" SEC_kconfigwidgets
!else
Section "-kconfigwidgets" SEC_kconfigwidgets
!endif
SetOutPath "$INSTDIR\bin"
File ${prefix}/bin/libKF6ConfigWidgets.dll

# This is a bit strange but these files are from the plasma repo
# but actually used by a class from KConfigWidgets so we install
# them here.
SetOutPath "$INSTDIR\share\color-schemes"
File /oname=Breeze.colors BreezeClassic.colors
File BreezeDark.colors

SectionEnd
