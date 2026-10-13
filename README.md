# steamify-gamescope-nvidia

[gamescope](https://github.com/ValveSoftware/gamescope) with GBM-allocated scan-out buffers, built for
[Steamify](https://github.com/theupriser/steamify-cachyos) on NVIDIA PCs.

gamescope's own gaming mode shows a corrupted picture on NVIDIA's DRM backend (artifacts, flicker, displaced strips;
see [ValveSoftware/gamescope#2309](https://github.com/ValveSoftware/gamescope/issues/2309)). Allocating the scan-out
buffers through GBM instead of Vulkan cures it. This repository keeps that patch and builds gamescope with it.

## Where the patch comes from

It is not our work. `gamescope-gbm-scanout.patch` is nine commits from
[farnoy/gamescope](https://github.com/farnoy/gamescope) (branch `nvidia-gbm-wayland`: `5cf847274`, `ffb525cf7`, `211f4ca26`,
`117b593ea`, `8da9459ff`, `cb0378edc`, `4e879fbf7`, `0c7fddbf3`, `ae7b99df3`), put into one diff against a gamescope release.
Its author noted that part of that work was AI-assisted. gamescope is BSD-2-Clause; so is this patch.

It is opt-in: it only takes effect with `gamescope_drm_gbm_scanout=1` in gamescope's environment (Steamify sets it).

## Tested

RTX 5080, driver 615.78.08, gamescope 3.16.31, 3440x1440@175 over DisplayPort: Steam's gaming UI is clean with the patch
and shows artifacts everywhere without it. Real games are not tested yet.

## Build and install (Arch, CachyOS)

    makepkg -f
    sudo pacman -U steamify-gamescope-nvidia-*.pkg.tar.zst

The package `provides` and `conflicts` with `gamescope`, and replaces `gamescope-nvidia-gbm`. It is pinned to the gamescope
release in `UPSTREAM_VERSION`: pacman does not update it by itself. Steamify shows a newer release and rebuilds.

## Staying current

`scripts/check-upstream.sh` finds the newest gamescope release and checks whether the patch still applies.
`.github/workflows/check-upstream.yml` runs it daily (a draft, not run yet): a clean patch gets a pull request that bumps
the version; a patch that no longer applies gets a pull request from Claude with a rebased patch. Nothing is merged or
released without a person looking at it, and a rebase still needs a look at the picture on an NVIDIA PC.

If upstream fixes the bug, this repository is no longer needed and Steamify goes back to the stock package.
