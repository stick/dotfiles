Dotfiles
--------

shell configuration files

There's a few interesting and neat things found within.

bin/homesync.sh does initial setup and linking (or copy syncing, but that part
doesn't work as well).  All files are assumed to be hidden (.{name}) unless a 
{name}.nodot exists.  It attempts to be smart about directories and link the 
contents if the directory exists otherwise link the directory.
