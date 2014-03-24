# Host support functions for UCIB.
#
#   This program is free software; you can redistribute it and/or modify it
#   under the terms of the GNU General Public License version 3, as
#   published by the Free Software Foundation.
#
#   This program is distributed in the hope that it will be useful, but
#   WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#   General Public License for more details.
#
#   You should have received a copy of the GNU General Public License along
#   with this program; if not, see <http://www.gnu.org/licences/>

# Ensure that a program is available.
#
# In order to be able to successfully build an image, many programs must be available.
# On a random user's system, there's no guarantee that all of those programs will
# be available already.  So, we need to do a few things:
#
# 1. Try and work out if the program *is* available already (ie it's
#    installed on the system);
#
# 2. Whether that program will do what we need it to (namespace collisions
#    and out-of-date versions are a PITA);
#
# 3. Work out where we might get the tool from if it isn't already there; and
#
# 4. Try and install it if necessary.
#
# This function tries to do all of those things.  So it needs a fair amount
# of information.
#
# Usage:
#
#    check_program_available <testcmd> <filename>
#
# The function will execute `<testcmd>`, and if that returns true (0), the
# command will be deemed "available" and we'll return successfully.  If
# `<testcmd>` returns false, then we'll count it as "not available".  All
# output from `<testcmd>` will be redirected to /dev/null.  Feel free to
# have your `<testcmd>` try to run the program with `--help` and grep for
# needed options, etc if necessary.
#
# If the program is deemed to be "not available", then this function will
# call `install_program_in_host`, which (by default) simply aborts the build
# and asks the user to install the software necessary by hand.  However,
# host OS plugins should override this default to provide a more intelligent
# way of automatically installing the necessary software (such as searching
# for the package that contains the program and installing it).  The
# `<filename>` parameter will be useful in this effort, as it is the typical
# name of the program on the system.
#
check_program_available() {
	local testcmd="$1"
	local filename="$2"
	
	debug "Checking if '$filename' is available by running '$1'"

	if eval "$testcmd" >/dev/null 2>&1; then
		debug "'$filename' is available and looks good"
		# Eeeexcellent...
		return 0
	fi
	
	debug "'$filename' does not appear to be available"
	
	install_program_in_host "$2"
	
	hash -r
	
	if ! eval "$testcmd" >/dev/null 2>&1; then
		fatal "The program '$filename' does not appear to be available,
		      and I could not automatically install a suitable package
		      to supply it.  Please install it manually."
	fi
}

check_program_available_by_grep() {
	local testcmd="$1"
	local filename="$2"
	
	debug "Checking if '$filename' is available by running '$1'"

	if eval "$testcmd" | grep $filename 2>&1; then
		debug "'$filename' is available and looks good"
		# Eeeexcellent...
		return 0
	fi
	
	debug "'$filename' does not appear to be available"
	
	install_program_in_host "$2"
	
	hash -r
	
	if ! eval "$testcmd" | grep $filename 2>&1; then
		fatal "The program '$filename' does not appear to be available,
		      and I could not automatically install a suitable package
		      to supply it.  Please install it manually."
	fi
}

# Default implementation of the `install_program_in_host` function.  Host OS
# plugins should *definitely* reimplement this themselves.
#
install_program_in_host() {
	local filename="$1"
	
	fatal "The program '$filename' does not appear to be available, or
	      does not provide the functionality we need.  Furthermore, we
	      are not running on an OS on which we know how to install the
	      correct package automatically.  Please install the necessary
	      software for '$filename' to run, and try again."
}
	
run_in_target() {
	chroot "$TARGET" "$@"
}
