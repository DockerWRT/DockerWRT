# DockerWRT
## Usable openwrt, docker and NAS

# To create firmware:
## make 

# To choose a tag:
## make OPENWRT_TAG=v23.05.2

# To create toolchain:
## make toolchain

# To using proxy:
## make CUSTOM_PROXY=http://192.168.10.2:1080

# To clean:
## make clean

# To distclean:
## rm -rf openwrt-src

# sample:
## make clean
## make PRODUCT_TARGET=x86_64 OPENWRT_TAG=v23.05.2 COMPILE_JOBS=-j6 COMPILE_VISUAL='V=99' CUSTOM_PROXY=http://192.168.10.2:1080 firmware
