# debian-live-build

All files and configs needed to build a custom Debian live iso with dwm.

_Note to self: keep a copy of the source code for dwm, st and dmenu in this repo so that it remains untouched if their main repos are modified. Also simplifies deploy.sh_

## Usage

**Get Live-Build**  
sudo apt install live-build  

**Create dir & Clone repo**  
mkdir -p .local/src  
cd .local/src  
git clone _repo_  
cd debian-live-build  
chmod u+x deploy.sh  
cd back to home dir  

**Make Work Dirs**  
mkdir .build/deb-live  

**Change Dir**  
cd .build/deb-live  

**Config command**  
lb config -d bullseye --debian-installer none --archive-areas "main contrib non-free" --debootstrap-options "--variant=minbase"  

```
Note: removed the installer, as I don't like installating live ISOs. To re-add the installer,  
change the "none" option in "--debian-installer" with cdrom, netinst, netboot, businesscard  
or live.
```

**Copy all files and configs**  
cd out of .build/deb-live  
run: .local/src/debian-live-build/deploy.sh  

**Build iso**  
cd .build/deb-live  
sudo lb build  

## Iso Notes
* The resulting iso uses doas instead of sudo.
* Password for doas: live

