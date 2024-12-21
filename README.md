## Setup env

1. Copy `.env.example` to `.env` and replace variables.
2. Add SSH keys to .shh folder (Optional)
3. Build image and run docker container.

> docker compose up -d --build

## Usage

1. Opens an interactive Bash shell in a container.

> docker exec -it env bash

## Build

1. Initialize source repository 

> repo init -u https://github.com/LineageOS/android.git -b lineage-21.0 --git-lfs

2. Download the source code

> repo sync

3. Start the build

> source build/envsetup.sh

> breakfast sdk_phone_arm64 eng

> mka

> mka emu_img_zip
