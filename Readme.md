

# LabCMake

Some utilities for cmake scripts in the Lab family of libraries.

At the moment it's pretty opinionated about structure.

In particular, it disagrees with CMake about whether or not installed
binary files should go in $(INSTALL_DIR)/bin, or $(INSTALL_DIR)/bin/Release
on Windows.

These utilities assume things are going into bin, and that debug libraries
are named with a suffix distinguishing them from release libraries.

The reason for going against CMake convention is that pretty much every
CMake script in existence looks for things in lib and bin, not lib/Release
or bin/Debug.

