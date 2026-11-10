# Fingerprint Setup

Get your laptop's fingerprint reader working on Ubuntu and other Debian-based Linux
distributions, even when the distribution's driver is too old to know it.

```bash
curl -fsSL https://raw.githubusercontent.com/rahul069/fingerprint-setup/main/install.sh | bash
```

That one command installs the tool, builds the driver, registers your finger and
asks whether to use it for login. Afterwards **Fingerprint Setup** is in your app
menu for everything else.

## Is this for me?

Run `fprintd-list $USER`. If it says **No devices available** although your laptop
has a fingerprint sensor, the driver library on your system (libfprint) is probably
too old for your sensor. Newer libfprint releases support many more sensors, but
distributions ship them slowly. For example, Ubuntu 24.04 has libfprint 1.94.7,
which does not know the FocalTech FT9349 (`2808:a99a`) in the ASUS ExpertBook P1403CVA.

Fingerprint Setup checks this for you and does nothing if your reader already works.

## What it does

1. Finds the fingerprint sensor on USB (FocalTech, Synaptics, Goodix, Elan,
   Validity, FPC, Egis and others).
2. Installs the build tools and `fprintd` from your distribution.
3. Downloads [libfprint](https://gitlab.freedesktop.org/libfprint/libfprint) from
   freedesktop.org at a pinned, tested commit and builds it.
4. Checks that this libfprint really supports your sensor. If not, it stops
   before changing anything.
5. Installs the library into `/usr/local` and restarts `fprintd`. Your
   distribution's packages are not modified, so system updates will not undo it.
6. Lets you register fingers and turn on fingerprint login (login screen, lock
   screen, `sudo`). Your password keeps working as before.

## The app

Open **Fingerprint Setup** from the app menu or run `fingerprint-setup gui`. It
shows the state of your sensor, driver, registered fingers and login, and lets you:

- install or update the driver
- register a finger, with hints while you touch the sensor
- test a finger
- turn fingerprint login on or off
- remove your fingerprints, or uninstall the driver

Steps that change the system ask for your password in the normal system dialog.

## Terminal commands

```
fingerprint-setup setup              guided setup: install, register a finger, turn on login
fingerprint-setup status             sensor, driver, registered fingers, login state
fingerprint-setup install            build and install libfprint (asks for your password)
fingerprint-setup enroll [FINGER]    register a finger (default right-index-finger)
fingerprint-setup verify             test a registered finger
fingerprint-setup delete             remove all your registered fingers
fingerprint-setup login on|off       fingerprint for login, lock screen and sudo
fingerprint-setup uninstall [--all]  remove the driver (--all: also remove this app)
```

`install --version <tag-or-commit>` builds a different libfprint version;
`install --force` builds even if no sensor is found or it already works.

Installer options: `... | bash -s -- --gui` opens the window instead of the
terminal setup, `... | bash -s -- --no-setup` only installs the app.

## Tips for reliable recognition

- Register each finger with **many different touches**: the flat pad, the tip,
  the left and right edges, a bit higher and lower. Lift the finger fully every time.
- Register a second finger, for example `fingerprint-setup enroll left-index-finger`.
- Fingerprint login allows 3 tries before asking for your password.
- After a reboot, GNOME asks for your password once to unlock the keyring. That is
  normal with fingerprint login.

## Undo everything

```bash
fingerprint-setup login off        # if you turned on fingerprint login
fingerprint-setup uninstall --all  # remove the driver and this app
```

The tool records every file it installs (`/usr/local/share/fingerprint-setup/installed-files`)
and removes exactly those. When your distribution ships a libfprint that supports
your sensor, uninstall it and the system version is used again.

## Files it touches

| Path | Why |
|---|---|
| `/usr/local/lib/libfprint-2.so*`, `/usr/local/include/libfprint-2/`, `/usr/local/lib/pkgconfig/libfprint-2.pc` | the newer driver library |
| `/etc/ld.so.conf.d/00-fingerprint-setup.conf` | makes sure `/usr/local/lib` is searched |
| `/usr/local/share/fingerprint-setup/` | installed version and file list |
| `/var/cache/fingerprint-setup/` | source code and build log |
| `/usr/share/pam-configs/fprintd` | only with `login on`: raises `max-tries` from 1 to 3 |
| `/usr/local/bin/fingerprint-setup`, `/usr/local/share/applications/fingerprint-setup.desktop` | the app itself |

## Supported systems

Tested on Ubuntu 24.04 with an ASUS ExpertBook P1403CVA (FocalTech FT9349,
`2808:a99a`). It should work on Debian 12+, Linux Mint, Pop!_OS and other
apt-based distributions with systemd. Whether your sensor works depends on libfprint;
see the [list of supported devices](https://fprint.freedesktop.org/supported-devices.html).

If something goes wrong, the build log is in `/var/cache/fingerprint-setup/build.log`.
Please open an issue with the output of `fingerprint-setup status` and `lsusb`.

## License

MIT for this tool. libfprint is downloaded from freedesktop.org and is licensed
under the LGPL-2.1.
