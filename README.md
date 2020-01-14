curl https://dl.google.com/android/repository/platform-tools-latest-linux.zip

- In .repo/local_manifests clone this repo: https://gitlab.com/switchroot/android/manifest
  - Clone it into local_manifests
  - git clone <url> local_manifests
  - in .repo
  - git clone https://gitlab.com/switchroot/android/manifest.git local_manifests

- now sync again
 
- after that you'll need to follow the readme for the patches. I'd suggest leaving out rsmouse right now just to make things simpler
- for the repopick stuff in there you run repopick -t nvidia-enhancements-p and repopick -t joycon-p