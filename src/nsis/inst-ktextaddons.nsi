# Copyright (C) 2024 g10 Code GmbH
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
!define prefix ${ipdir}/ktextaddons-${gpg4win_pkg_ktextaddons_version}

Section "-ktextaddons" SEC_ktextaddons
  SetOutPath "$INSTDIR\bin"
  File ${prefix}/bin/libKF6TextAddonsWidgets.dll
  File ${prefix}/bin/libKF6TextAutoCorrectionCore.dll
  File ${prefix}/bin/libKF6TextAutoCorrectionWidgets.dll
  File ${prefix}/bin/libKF6TextCustomEditor.dll
  File ${prefix}/bin/libKF6TextEmoticonsCore.dll
  File ${prefix}/bin/libKF6TextEmoticonsWidgets.dll
  File ${prefix}/bin/libKF6TextGrammarCheck.dll
  File ${prefix}/bin/libKF6TextTranslator.dll
  File ${prefix}/bin/libKF6TextUtils.dll
SectionEnd
