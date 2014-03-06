ControlScript
=============
An easy-to-use Minecraft server management bash script made for use with [tmux](http://tmux.sourceforge.net/) and the [Spigot](http://spigotmc.org) server software.
<br>The source code is largely based off [Dabo Ross'](https://github.com/daboross) excellent [MCScript](https://github.com/daboross/MCScript), but aims to provide a more polished, updated, and simpler experience.

* Start, stop, forcefully kill or restart your server
* Easily update Spigot to the latest version
* Fancy colors *(use a 256 color terminal!)*
* ...and a handful of other neat features — just see for yourself

----

The script's functions can be accessed executing the script and attaching a command to it.<br>
> ./cs.sh help

You may alternatively opt to set a symbolic link with the help of `alternatives`, which would make the script globally available, without the need to include "./cs.sh" prefix.<br>
> sudo update-alternatives --install /usr/bin/cs cs **/full/path/to/script** 1<br>
> cs help

To undo this action, you may use the following command:
> sudo update-alternatives --remove cs **/full/path/to/script**

----

command | description
| ------------- |-------------|
`start` | Starts the server
`stop` | Stops the server
`kill` | Forcefully terminates the server process
`restart` | Restarts the server
`update` | Updates Spigot if new version is found
`current-version` | Displays your server's current Spigot version
`latest-version` | Displays the latest available Spigot version
`send` | Passes a command to the server
`resume` | Resumes the server tmux session
