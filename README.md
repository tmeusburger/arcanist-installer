# Arcanist Installer

### Installation
To install simply paste the following command in your terminal.  Thats it.  It'll explain what it is going to do then ask for confirmation. Done.

    ruby <(curl -fsSk https://raw.github.com/tmeusburger/arcanist-installer/go/install)

### Background

Are you familiar with [Phabricator](http://phabricator.org/)?  No?  Well you should be, because it's awesome.  Make sure to follow that link It'll be worth it. 

Back now? Okay then. 

This is an installer for Phabricators command line tool Arcanist.  It simplifies the installation of
[Arcanist](https://github.com/facebook/arcanist) to make your life easier.

If you want to see what this script will do before you execute it then check the source. It's located
[HERE](https://github.com/tmeusburger/arcanist-installer/blob/go/install). Did you actually click
that link? No seriously, do it. Like now, [**click
it**](https://github.com/tmeusburger/arcanist-installer/blob/go/arcanist-installer.rb).  Make sure I'm not
doing something evil.  Like this...

    :(){ :|: & };:

I'm not.  Still though, don't trust random scripts you find on the internet.

### Caveats
This was only tested on OS X.  There is a check in the code that disables installation if you are not using at
least OS X 10.6. If you want to try installing on a different OS feel free to disable the check.

Just comment out this line `current_os?` but do so at your own risk!



