## Setup env

1. Copy `.env.example` to `.env` and replace variables.
2. Add SSH keys to .shh folder.
3. Build image and run docker container.

> docker compose up -d --build

4. Open an interactive Bash shell in a container.

> docker exec -it env bash

5. Setup SSH agent.

> eval "$(ssh-agent -s)"
> ssh-add ~/.ssh/id_ed25519

## Usage

1. Opens an interactive Bash shell in a container.

> docker exec -it env bash

## Build

1. Initialize source repository.

> repo init -u https://github.com/StockAOSP/android.git -b 15.1 --git-lfs --no-clone-bundle

2. Download the source code.

> repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags --optimized-fetch --prune

3. Start the build.

> source build/envsetup.sh

> breakfast sdk_phone_arm64 eng

> mka

> mka emu_img_zip
