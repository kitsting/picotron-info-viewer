# Info Viewer
This is a commandline-based command list and manual viewer for Picotron.
You can see more info in the [BBS post](https://www.lexaloffle.com/bbs/?tid=140840)

## How do I install it?
In addition to the installation methods in the BBS post, you can also put the source code for this project into your picotron drive, load it directly, and then press CTRL-R to "install" it.
If you would prefer to do it manually, then you can make a file called `infman.p64` in your `/appdata/system/util/` folder, and put the source code into there

## How do I use it?
Once the utility is installed, you can type `infman` to get a list of commands, or `infman [command name]` to get a manual for that command.

Full usage: `infman [options] [command name] [page]`
- Flags include:
    - `-s` or `--system` to list only system commands
    - `u` or `--user` to list only user (custom) commands
    - `h` or `--highlight` to highlight commands without a manual in red
- `[page]` is the page of the manual to view. If no page is given, it defaults to 1


You can add custom manual pages by:
- Adding a multiline comment to the top of the command's code
- Making a file named `[command]_manual.txt` in the same directory as the command
- Mading a file called `manual.txt` alongside `main.lua` if the command is a `.p64` file

Add page breaks to your manuals by putting `---` on a line all by itself

p8scii formatting for manuals is (somewhat) supported
