# 🔨 bsys5

This repo contains scripts and assets to build the
[LibreWolf source tarball](https://gitlab.com/librewolf-community/browser/source)
for various platforms with docker, as well as binary releases produced by those
scripts.

<a href="https://gitlab.com/librewolf-community/browser/bsys5/-/releases"><img src="https://img.shields.io/badge/%F0%9F%93%A5-Go to Releases-blue?style=flat" height="30px"></a>

## <a id="targets"></a> Supported Targets

| Platform        | x86_64                            | aarch64            |
| --------------- | --------------------------------- | ------------------ |
| Linux           |                                   |                    |
| └─ Debian (deb) | ✅ (debian11)                     | -                  |
| └─ Ubuntu (deb) | ✅ (ubuntu20, ubuntu21, ubuntu22) | -                  |
| └─ Mint (deb)   | ✅ (mint20)                       | -                  |
| └─ Fedora (rpm) | ✅ (fedora35, fedora36)           | -                  |
| MacOS (dmg)     | ✅ (macos-x64_64)                 | ✅ (macos-aarch64) |
| Windows         | _WIP_                             | -                  |

## Running bsys5 Locally

> Note: Bsys5 only works on Linux. Other platforms are cross-compiled from
> Linux.

To build LibreWolf with bsys5 locally, just install
[Docker](https://docs.docker.com/engine/install/) and then clone this
repository. Then you can just build the target you want with:

`make <TARGET>`, for example `make ubuntu22`\
(See [the above table](#targets) or `make help` for a list of supported targets.)

This will pull a prebuilt build environment from
[this repository](https://gitlab.com/librewolf-community/browser/bsys5/container_registry).
If you also want to build that yourself, run `make docker-<TARGET>` first.
