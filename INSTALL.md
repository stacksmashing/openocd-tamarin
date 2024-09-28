For Windows, you can download the latest prebuilt release [here](https://github.com/stacksmashing/openocd-tamarin/releases/tag/latest).

For macOS, we prepared a custom homebrew tap, and so if you have Homebrew installed you can just run:

```
brew tap stacksmashing/homebrew-tap
brew install --HEAD stacksmashing/tap/openocd-tamarin
```

If you need to update the openocd version, run:

```
brew upgrade stacksmashing/tap/openocd-tamarin --fetch-HEAD
```

For Linux, you most probably need to build OpenOCD from source, our Github repository with Faultier compatibility can be found [here](https://github.com/stacksmashing/openocd-tamarin)!

On Linux you will also need a udev rule so that your user can access Faultier. For example:

```
SUBSYSTEM=="usb", ATTR{idVendor}=="2B3E", ATTR{idProduct}=="2343", MODE="0666" 
```
in /etc/udev/rules.d/99-faultier.conf. Reboot after adding this line to make sure the changes take effect. Note that this will grant any user on the system access to Faultier.

