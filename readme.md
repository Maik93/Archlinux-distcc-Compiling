# Distrubuted compiling for Achlinux clients to any volunteer (though docker)
The system that starts the build is the `client`, while the workers are the `volunteers`.
If you want to use the client system to compile as well, apply the client configuration to it.
You can set each host that will start a build as `client`.

Keep in mind that only compiles are distributed; preprocessing and linking still takes place on the client system.

On any system install `distcc` (and `ccache` because it always helps):
```sh
pacman -S distcc ccache
```

## Client configuration
Enable `distcc` and `ccache` in `/etc/makepkg.conf` by removing the prepended `!`.
Change `DISTCC_HOSTS` to a space-delimited list of the clients on your network.
If you want to use the client system, be sure to put it's IP address in there too.
Referred guides suggest to avoid the usage of "localhost" or "127.0.0.1".

```sh
sudo sed -i 's/!distcc/distcc/' /etc/makepkg.conf
sudo sed -i 's/!ccache/ccache/' /etc/makepkg.conf
sudo sed -i 's,#DISTCC_HOSTS="",DISTCC_HOSTS="10.30.5.3/20,cpp,lzo",' /etc/makepkg.conf
```
The setup above uses just the '10.30.5.3' server, limiting to 20 cores (yeah, that's not the subnet mask).
The trailing `,cpp,lzo` is optional and instruct distcc to perform in _pump mode_, reportely more efficient. Each volunteer that has it, will compile more than the other ones.

Distribution status can be displayed with `distccmon-text 2` (the number is refresh time, in seconds).

NOTE: client nodes *cannot* have `-march=native` in CFLAGS or CXXFLAGS, otherwise distccd will not distribute work to other machines!

### How to distribute custom commands
Specific commands can be distributed with volunteers with the `pump` command, e.g.:
```sh
export DISTCC_HOSTS="10.30.5.3/20,cpp,lzo localhost" # <- can be placed in .zshrc
pump make -j40 CC=distcc CXX=distcc
```

## Volunteer configuration
Specify accepted connections in `/etc/conf.d/distccd`:
```
DISTCC_ARGS="--allow-private --log-level info --log-stderr --log-file /tmp/distccd.log"
```
This opens to any volunteer in the local network. Otherwise, specific IPs can be set with `--allow 127.0.0.1 --allow 10.30.5.0/24`.

Enable and start `distccd.service`.

Each volunteer can be monitored by the HTTP statistics server at port `3633` by adding `--stats` to `DISTCC_ARGS`.

## References
- [Distributed compiling setup](https://archlinuxarm.org/wiki/Distributed_Compiling)
- [Cross compiling for Archlinux ARM](https://archlinuxarm.org/wiki/Distcc_Cross-Compiling)
- [Arch Wiki for distcc](https://wiki.archlinux.org/title/Distcc)
