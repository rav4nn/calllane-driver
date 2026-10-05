# CallLane driver

The Core Audio driver that the [CallLane](https://calllane.hardeep.cv) macOS app installs. It adds a
`CallLane` output device for call apps and a hidden `CallLane Tap` input that the app reads.

It is a derivative of [BlackHole](https://github.com/ExistentialAudio/BlackHole) and is licensed under
GPL-3.0, the same as BlackHole. See `NOTICE` for what changed and `LICENSE` for the licence.

Build: `make driver` (ad-hoc signed) or `make pkg` for the installer package. `make install-driver`
installs it into `/Library/Audio/Plug-Ins/HAL`.
