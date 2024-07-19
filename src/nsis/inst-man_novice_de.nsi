# inst-man_novice_de.nsi - Installer snippet       -*- coding: latin-1; -*-
# Copyright (C) 2005 g10 Code GmbH
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


${MementoSection} "$(DESC_Name_man_novice_de)" SEC_man_novice_de
  SetOutPath "$INSTDIR"
!ifdef SOURCES
  # No need to include anything as the manuals are part of gpg4win
  # File "${gpg4win_pkg_man_novice_de}"
!else

  SetOutPath "$INSTDIR\share\gpg4win"
  File "${BUILD_DIR}/../doc/manual/einsteiger.pdf"
!endif
${MementoSectionEnd}


LangString DESC_Name_man_novice_de ${LANG_ENGLISH} \
   "Novice Manual (German)"

LangString DESC_SEC_man_novice_de ${LANG_ENGLISH} \
   "Gpg4Win Manual for the Novice User (German)"

LangString DESC_Menu_man_novice_de ${LANG_ENGLISH} \
   "Show the German online manual of Gpg4Win for novice users"
