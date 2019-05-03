---
title: Nextcloud Client Packages for Debian
---

# DEPRECATED

This repository is no longer maintained.
Packages of the Nextcloud desktop client are now available in
  [stretch-backports](https://packages.debian.org/stretch-backports/nextcloud-desktop) and
  [buster](https://packages.debian.org/buster/nextcloud-desktop).

## What should I do now?

If you used this repository before, please do the following.

Quit the Nextcloud client.

Remove the old package and repository:

1. `sudo apt remove --purge nextcloud-client && sudo apt autoremove --purge`

2. `sudo rm /etc/apt/sources.list.d/nextcloud-client-m4lvin.list`

3. `sudo apt-key del 749224A4AF352B44511E050E7E420D98B2CF44CE`

4. `sudo apt update`

Then you can install the new package from `stretch-backports` as follows:

1. Ensure you have `deb https://deb.debian.org/debian stretch-backports main` in your `/etc/apt/sources.list`.

2. `sudo apt update && sudo apt install -t stretch-backports nextcloud-desktop`

3. If you want dolphin integration, also do `sudo apt install -t stretch-backports dolphin-nextcloud`.

Alternatively, you can use the [AppImage from nextcloud.com](https://nextcloud.com/install/#install-clients).
