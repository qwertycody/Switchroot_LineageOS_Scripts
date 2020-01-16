- Info from hans on imaging a device directly instead of using fastboot
  - @QwertyCody you can. Boot, recovery and dtb can just flashed with dd. For system and vendor you need to get simg2img and convert them to raw image and then you can flash them with dd.

- Build errors for ninja:
  - Solution
    -   clean 
        run lunch
        make clean bootimage ? 
  - Error
    -   [1/1] /home/marek/android/lineage/out/soong/.bootstrap/bin...ng_build /home/marek/android/lineage/out/soong/build.ninja
        FAILED: /home/marek/android/lineage/out/soong/build.ninja
        /home/marek/android/lineage/out/soong/.bootstrap/bin/soong_build -t -l /home/marek/android/lineage/out/.module_paths/Android.bp.list -b /home/marek/android/lineage/out/soong -n /home/marek/android/lineage/out -d /home/marek/android/lineage/out/soong/build.ninja.d -o /home/marek/android/lineage/out/soong/build.ninja Android.bp
        error: vendor/lineage/build/soong/Android.bp:31:8: module "generated_kernel_includes": cmd: unknown variable '$(KERNEL_MAKE_FLAGS)'
        ninja: build stopped: subcommand failed.
        19:31:56 soong bootstrap failed with: exit status 1
        build/make/core/main.mk:21: recipe for target 'run_soong_ui' failed
        make: *** [run_soong_ui] Error 1