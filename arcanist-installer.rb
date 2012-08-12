#!/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/bin/ruby
# This is a installer for the command line tool arcanist.
# This installer was ONLY written for mac os x in mind.  Use at your own risk if you choose to try and install
#   this on a linux distro.
#
# Give credit where credit is due -- https://raw.github.com/mxcl/homebrew/go
# This script was based on the awesome homebrew installer

# This script installs to /usr/local only. To install elsewhere you will have to manually do it yourself!
# --- Manual Install to /usr/local ---
#  mkdir /usr/local/phabricator
#  chmod g+rwx /usr/local/phabricator
#  chgrp admin /usr/local/phabricator
#  cd /usr/local/phabricator
#  git clone https://github.com/facebook/arcanist.git
#  git clone https://github.com/facebook/libphutil.git 
#  ln -s /usr/local/phabricator/arcanist/bin/arc /usr/local/bin/arc

# --- Manual Install to home directory ---
#  mkdir ~/phabricator
#  cd ~/phabricator
#  git clone https://github.com/facebook/arcanist.git
#  git clone https://github.com/facebook/libphutil.git 
#  ln -s ~/phabricator/arcanist/bin/arc /usr/local/bin/arc


ARCANIST_INSTALL_LOCATION = "/usr/local/phabricator"
USR_LOCAL_BIN = "/usr/local/bin"

module Tty extend self
  def blue; bold 34; end
  def white; bold 39; end
  def red; underline 31; end
  def reset; escape 0; end
  def bold n; escape "1;#{n}" end
  def underline n; escape "4;#{n}" end
  def escape n; "\033[#{n}m" if STDOUT.tty? end
end

class Array
  def shell_s
    cp = dup
    first = cp.shift
    cp.map{ |arg| arg.gsub " ", "\\ " }.unshift(first) * " "
  end
end

def ohai *args
  puts "#{Tty.blue}==>#{Tty.white} #{args.shell_s}#{Tty.reset}"
end

def warn warning
  puts "#{Tty.red}Warning#{Tty.reset}: #{warning.chomp}"
end
 
def system *args
  abort "Failed during: #{args.shell_s}" unless Kernel.system *args
end

def sudo *args
  args = if args.length > 1
    args.unshift "/usr/bin/sudo"
  else
    "/usr/bin/sudo #{args.first}"
  end
  ohai *args
  system *args
end

def getc  # NOTE only tested on OS X
  system "/bin/stty raw -echo"
  if RUBY_VERSION >= '1.8.7'
    STDIN.getbyte
  else
    STDIN.getc
  end
ensure
  system "/bin/stty -raw echo"
end

def macos_version
  @macos_version ||= /(10\.\d+)(\.\d+)?/.match(`/usr/bin/sw_vers -productVersion`).captures.first.to_f
end

def file_exists file_path
  File.exists?(file_path) || File.symlink?(file_path)
end


#### Validation functions ####


# Leaving this here even though it should work regardless of version number.
# I have no way to test Mac OS versions before 10.6 to verify, comment out the following line at your own risk.
def current_os? 
  abort "MacOS too old, upgrade to at least 10.6" if macos_version < 10.5 
end

def not_root?
  abort "Don't run this as root!" if Process.uid == 0
end

def git_installed?
abort <<-EOABORT if `which git`.strip == ""
Git does not appear to be installed on this machine.  Please install it before tyring to install arc.

Installing Git:
  If you have homebrew installed just type
  'brew install git'

  Othwerise use one of the following links
    http://git-scm.com/downloads/
    http://code.google.com/p/git-osx-installer/  
EOABORT
end

def user_admin?
abort <<-EOABORT unless `groups`.split.include? "admin"
This script requires the user #{ENV['USER']} to be an Administrator.  Theoretically you're a developer
installing ARC on your machine so this shouldn't be a problem.  Just make sure your on the right user account
before rerunning the script
EOABORT
end

def arcanist_already_installed?
abort <<-EOABORT if file_exists ARCANIST_INSTALL_LOCATION 
#{ARCANIST_INSTALL_LOCATION} already exists!  Looks like you've already installed this software. 
If you wish to proceed with installation manually delete #{ARCANIST_INSTALL_LOCATION}.

Type 'arc upgrade' to upgrade your current installation instead of reinstalling.
EOABORT
end

def arcanist_already_symlinked?
abort <<-EOABORT if file_exists "/usr/local/bin/arc"
It seem's you already have a peice of software installed called arc in /usr/local/bin.  If this is the case you've
either installed arcanist previously or have a conflicting piece of software installed with the same name.  You
should either uninstall the conflicting arc software or execute a manual install.

Conflict: /usr/local/bin/arc 
EOABORT
end

####################################################################### script

# Do some checks, abort if any failures occur
current_os?
not_root?
git_installed?
user_admin?
arcanist_already_installed?
arcanist_already_symlinked?

ohai "This script will install:"
puts "/usr/local/bin/arc"
puts "/usr/local/phabricator/"
puts "/usr/local/phabricator/arcanist/..."
puts "/usr/local/phabricator/libphutil/..."

ohai "The following directories will be made group writable and their group set to #{Tty.underline 39}admin#{Tty.reset}:"
puts "/usr/local/phabricator"
puts "/usr/local/phabricator/arcanist/..."
puts "/usr/local/phabricator/libphutil/..."

if STDIN.tty?
  puts
  puts "Press enter to continue"
  c = getc
  # we test for \r and \n because some stuff does \r instead
  abort unless c == 13 or c == 10
end
 
if File.directory? "/usr/local"
  sudo "/bin/mkdir #{ARCANIST_INSTALL_LOCATION}" unless file_exists ARCANIST_INSTALL_LOCATION 

  # The reason we do this it to allow upgrading of arcanist through 'arc upgrade' without requiring sudo
  sudo "/bin/chmod", "g+rwx", ARCANIST_INSTALL_LOCATION
  sudo "/usr/bin/chgrp", "admin", ARCANIST_INSTALL_LOCATION
end

Dir.chdir ARCANIST_INSTALL_LOCATION do
  ohai "Downloading and Installing Arcanist..." 
  system "git clone https://github.com/facebook/arcanist.git"
  ohai "Downloading and Installing libphutil..."
  system "git clone https://github.com/facebook/libphutil.git"
  ohai "Linking /usr/local/phabricator/arcanist/bin/arc to /usr/local/bin/arc..."
  sudo "/bin/ln -s #{ARCANIST_INSTALL_LOCATION}/arcanist/bin/arc #{USR_LOCAL_BIN}/arc"
end

warn "/usr/local/bin is not in your PATH.  Arcanist will not work unless you place /usr/local/bin in your PATH" unless ENV['PATH'].split(':').include? '/usr/local/bin'

puts ""
ohai "Installation successful!"
puts ""
puts "To confirm installation please type:" 
puts "  arc help"
puts "  arc upgrade"
puts "If neither command errors out the install was *truly* successful"
