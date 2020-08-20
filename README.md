_TH07: Perfect Cherry Blossom_ for Linux packaged as a flatpak.  

# Installation
Dependencies:

  - `flatpak` and `flatpak-builder`
  - ISO with TH07 game  
    (or make an archive from the disc and name it TH07.iso)

## Installing:
### Install pre-requisites
#### SDK
```
$ flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
$ flatpak install flathub org.freedesktop.Platform//19.08 org.freedesktop.Sdk//19.08 org.freedesktop.Platform.Compat.i386//19.08 org.freedesktop.Platform.GL32//19.08 --system
```
#### Wine
You will need to build `org.flathub.WineBaseApp` and `org.winehq.Wine` from <https://github.com/gasinvein/flatpak-apps-staging>

1. Clone with:
   ```
   $ git clone https://github.com/gasinvein/flatpak-apps-staging.git -b org.flathub.WineBaseApp/master org.flathub.WineBaseApp
   $ git clone https://github.com/gasinvein/flatpak-apps-staging.git -b org.winehq.Wine/master org.winehq.Wine
   ```
2. For each directory, build and install with:
    1. org.flathub.WineBaseApp
       ```
       $ flatpak-builder builddir org.flathub.WineBaseApp.yml --disable-updates --force-clean --install --user
       ```
    2. org.winehq.Wine
       ```
       $ flatpak-builder builddir org.winehq.Wine.yml --disable-updates --force-clean --install --user
       ```

### Build + Install TH07: PCB
1. Clone this repo
2. Place TH07.iso inside
3. Build with:
   ```
   $ flatpak-builder builddir local.touhou.PerfectCherryBlossom.yml --force-clean --install --user
   ```

# Running
## Original
You can use your DE shortcuts or run directly from console with:
```
$ flatpak run local.touhou.PerfectCherryBlossom
```

## Using patches (THCRAP)

### Permission override
To use patches, you will need to adjust the permissions for this package.  
Execute:
```
flatpak override --allow=devel --share=network local.touhou.PerfectCherryBlossom --user
```

Permission rundown:

  - `--allow=devel` is required for thcrap_loader to work
  - `--share=network` for thcrap_configure to fetch patches from the Internet.

### Using THCRAP
Launched via DE shortcuts or console, there are two phases:

  1. Patch configuration (`thcrap_configure`)
     ```
     $ flatpak run local.touhou.PerfectCherryBlossom thcrap-conf
     ```
  2. Launching patched game (`thcrap_loader`)
     ```
     $ flatpak run local.touhou.PerfectCherryBlossom config-select
     ```

#### Patch configuration
Pretty straightforward except you don't need to create shortcuts since they're never used.  
When asked for game directory, select `/app/th07`.

#### Launching patched game
Straightforward, select the config you want to use with the GUI.

# QA
#### Binary build?  
No, the package needs the game files during the build phase, you will need to source the game yourself.

#### What are the patches in `patch/` and how were they generated?
They're patches to upgrade your game to version 1.00b (from 1.00 that comes with the ISO/disc).  
The official updater doesn't work under _Wine_ and we need the game to be updated during package generation
since `/app` directory is Read-Only, therefore we apply it via `bspatch`.  
The `.bspatch` files were made with `bsdiff` (<https://www.daemonology.net/bsdiff/>) by comparing the original game files with the updated game (by applying the official updater under a Windows installation).  
For reference, the original updater can be found at:

> <https://www16.big.or.jp/~zun/data/soft/youmu_update100b.lzh>  
  sha256sum: c7549e4689f6c1351101dadac0dde17bd9a13450853bc4367c2ce8434fdb6d1e


#### Support for UTL (Universal THCRAP Launcher)?
UTL is broken under Wine.  
It's also not needed since similar functionality is already provided.

#### License
Except for the `.bspatch` files, `COPYING` and `th07.png`, all the files here are under __Creative Commons CC0__.
