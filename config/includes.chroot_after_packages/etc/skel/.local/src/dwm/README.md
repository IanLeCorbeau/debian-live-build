Personal build of Suckless' dwm (Dynamic Window Manager)

### Applied Patches
  * [Fullgaps](https://dwm.suckless.org/patches/fullgaps/)
  * [Bottomstack](https://dwm.suckless.org/patches/bottomstack/) (with gaps)
  * [Rightmaster]() (with gaps)
  * [Pertag](https://dwm.suckless.org/patches/pertag/)
  * [Rotatestack](https://dwm.suckless.org/patches/rotatestack/)
  * [Titlecolor](https://dwm.suckless.org/patches/titlecolor/)

#### Other modifications
  * No spawn function. Dmenu, st and any other program needs to be launched via sxhkd or xbindkeys (etc).
  * Gaps in Monocle mode.
  * Option to adjust the status bar's height.
  * Floating windows always open in the center of the screen.

_Unfortunately, I don't remember where I got the code for the status bar height and the centered floating windows, but if I ever do, I'll give proper credit._

-----------------

dwm - dynamic window manager
============================
dwm is an extremely fast, small, and dynamic window manager for X.


Requirements
------------
In order to build dwm you need the Xlib header files.


Installation
------------
Edit config.mk to match your local setup (dwm is installed into
the /usr/local namespace by default).

Afterwards enter the following command to build and install dwm (if
necessary as root):

    make clean install


Running dwm
-----------
Add the following line to your .xinitrc to start dwm using startx:

    exec dwm

In order to connect dwm to a specific display, make sure that
the DISPLAY environment variable is set correctly, e.g.:

    DISPLAY=foo.bar:1 exec dwm

(This will start dwm on display :1 of the host foo.bar.)

In order to display status info in the bar, you can do something
like this in your .xinitrc:

    while xsetroot -name "`date` `uptime | sed 's/.*,//'`"
    do
    	sleep 1
    done &
    exec dwm


Configuration
-------------
The configuration of dwm is done by creating a custom config.h
and (re)compiling the source code.

-------

#### _See LICENSE file for copyright and license details_
