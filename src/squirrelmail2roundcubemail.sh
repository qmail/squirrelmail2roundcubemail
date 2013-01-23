#!/bin/bash
#
# Copyright (C) 2010 Alessandro De Zorzi - www.rhx.it
# Copyright (C) 2013 Johannes Weberhofer, Weberhofer GmbH 
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
# 

ABOOKDIR="/var/lib/squirrelmail/prefs"

SCRIPT=`readlink -f "$0"`
pushd `dirname "$SCRIPT"`

for i in `ls -1 $ABOOKDIR/*.abook`; do
    iconv --from-code=ISO-8859-1 --to-code=UTF-8 "$i" > "$i.1"
    ./sm2rc_addressbook.pl "$i.1"
    rm -f "$i.1"
done
