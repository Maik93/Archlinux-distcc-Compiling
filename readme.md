# Distrubuted compiling for Achlinux masters to any slave (though docker)
The system that starts the build is the `master`, while the workers are the `clients`.
If you want to use the master system to compile as well, apply the client configuration to it.
You can set each host that will start a build as `master`.

Keep in mind that only compiles are distributed; preprocessing and linking still takes place on the master system.

On any system install `distcc`:
```sh
pacman -S distcc
```

## Master configuration
Enable `distcc` in `/etc/makepkg.conf` by removing the prepended `!`.
Change `DISTCC_HOSTS` to a space-delimited list of the clients on your network.
If you want to use the master system, be sure to put it's IP address in there too.
Referred guides suggest to avoid the usage of "localhost" or "127.0.0.1", I don't know why.

```sh
sudo sed -i 's/!distcc/distcc/' /etc/makepkg.conf
sudo sed -i 's,#DISTCC_HOSTS="",DISTCC_HOSTS="10.30.5.9/20",' /etc/makepkg.conf
```
The setup above uses just the Ryzen server, limiting to 20 cores (max. 32).

Distribution status can be displayed with `distccmon-text 2` (the number is refresh time, in seconds).

NOTE: master nodes *cannot* have `-march=native` in CFLAGS or CXXFLAGS!

### How to distribute custom commands
Specific commands can be distributed with slaves with the `pump` command, e.g.:
```sh
export DISTCC_HOSTS="10.30.5.9/30,cpp,lzo localhost" # <- can be placed in .zshrc
pump make -j40 CC=distcc CXX=distcc
```

## Slave configuration
Specify accepted connections in `/etc/conf.d/distccd`:
```
DISTCC_ARGS="--allow-private --log-level info --log-stderr --log-file /tmp/distccd.log"
```
Specific IPs can be specified, e.g. with `--allow 127.0.0.1 --allow 10.30.5.0/24`.
Then enable and start `distccd.service`.
Each slave can be monitored by the HTTP statistics server at port `3633` by adding `--stats` to `DISTCC_ARGS`.

## References
- [Distributed compiling setup](https://archlinuxarm.org/wiki/Distributed_Compiling)
- [Cross compiling for Archlinux ARM](https://archlinuxarm.org/wiki/Distcc_Cross-Compiling)
- [Arch Wiki for distcc](https://wiki.archlinux.org/title/Distcc)

