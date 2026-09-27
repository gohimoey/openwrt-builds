#!/usr/bin/env bash
set -euo pipefail
BASE=/opt/data/projects/openwrt-builder/25.12.5
export LD_LIBRARY_PATH=/opt/data/tools/gawkdeb/usr/lib/x86_64-linux-gnu${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
export IB="$BASE/extract/openwrt-imagebuilder-25.12.5-x86-64.Linux-x86_64"
export SHELL=/bin/bash
export PATH="/usr/bin:/bin:/opt/data/tools/gawkdeb/usr/bin:$BASE/make-local/usr/bin:$IB/staging_dir/host/bin"
export PACKAGE_DIR="$BASE/packages"
cd "$IB"

# Source of truth untuk etc/: repo git. Tanpa cp ini, semua edit
# network/wireless/uci-defaults di repo TIDAK ikut ke image.
SRC="${SRC:-/opt/data/projects/openwrt-modem-wifi-builder}"
[ -d "$SRC/files" ] || { echo "[!] $SRC/files tidak ada — set SRC=<path repo>"; exit 1; }

mkdir -p files/etc/uci-defaults files/etc/config
cp -a "$SRC/files/." files/
echo "[*] Synced $SRC/files -> $IB/files"
find files -type f | sed 's/^/    /'
cat > files/README-OPENWRT.txt <<'EOF'
OpenWrt 25.12.5 x86-64 UEFI — custom build "Masta-GOHIM"

AKSES (default)
  Router / LuCI : http://192.168.1.1
  SSH           : ssh root@192.168.1.1
  Username      : root
  Password      : (kosong / no password)
  Wireless      : Masta Gohim  (open, no password)
  Hostname      : Masta-GOHIM

DRIVER
  WiFi  : MT7921/MT7922 (mt7921e, mt7921s, mt7921u, mt792x-usb), MT7615, MT7915, MT76
  5G    : Quectel RM520N-GL — MHI PCIe (mhi_bus/mhi_net/mhi_wwan_ctrl)
          + USB QMI/MBIM/NCM (qmi_wwan, cdc_mbim, cdc_ncm, option)
  USB   : xHCI/EHCI/OHCI/UHCI, storage, hub

PAKET
  LuCI (theme openwrt) · PassWall · OpenClash · MWAN3 · Tailscale
  AdGuardHome · FileBrowser · Watchcat · Statistics · SQM · nlbwmon
  Samba · ModemManager · uqmi/libqmi/qmi-utils · parted/gdisk/smartmontools
  block-mount · htop · nano · bash · tmux
EOF

# board.json: M90n mini PC. Ports dikosongkan — 50-lan-detect yang
# menentukan port asli saat boot. Hardcode eth0/eth1 bikin bridge
# tidak terbentuk kalau port tsb tidak ada.
cat > files/etc/board.json <<'EOF'
{"model": "ThinkCentre M90n (x86-64)", "network": {}, "modalias": "openwrt-x86-generic"}
EOF

PACKAGES="luci luci-ssl luci-theme-openwrt luci-proto-ipv6 luci-app-firewall luci-app-package-manager luci-mod-system luci-mod-network luci-mod-status luci-app-attendedsysupgrade luci-app-upnp luci-app-ddns luci-app-samba4 luci-app-tailscale-community tailscale luci-app-filebrowser luci-app-watchcat luci-app-sqm luci-app-nlbwmon luci-app-irqbalance luci-app-adguardhome adguardhome luci-app-mwan3 mwan3 luci-app-banip luci-app-commands luci-app-wol luci-app-uhttpd kmod-usb-core kmod-usb2 kmod-usb3 kmod-usb-xhci-hcd kmod-usb-ohci-pci kmod-usb-uhci kmod-fs-ext4 kmod-fs-ntfs3 kmod-fs-exfat kmod-fs-f2fs kmod-fs-hfsplus kmod-fs-btrfs kmod-usb-net kmod-usb-net-asix kmod-usb-net-asix-ax88179 kmod-usb-net-rtl8152 kmod-usb-net-cdc-ether kmod-usb-serial kmod-usb-serial-wwan kmod-usb-serial-option usb-modeswitch modemmanager kmod-e1000 kmod-e1000e kmod-igb kmod-igc kmod-r8169 kmod-ixgbevf kmod-vmxnet3 kmod-iwlwifi kmod-ath9k kmod-ath10k ip-full wpad-mbedtls wireless-tools iperf3 samba4-server aria2 curl htop nano bash tmux block-mount kmod-crypto-hash kmod-crypto-sha256 luci-app-openclash luci-app-passwall kmod-mt7921e kmod-mt7921-common kmod-mt7921-firmware kmod-mt7921s kmod-mt7921u kmod-mt7922-firmware kmod-mt792x-common kmod-mt792x-usb kmod-mt7615e kmod-mt7615-common kmod-mt7615-firmware kmod-mt7915e kmod-mt7915-firmware kmod-mt7916-firmware kmod-mt76x2 kmod-mt76x2-common kmod-mt76x02-usb kmod-mt76-core kmod-mt76-usb kmod-mhi-bus kmod-mhi-net kmod-mhi-wwan-ctrl kmod-mhi-wwan-mbim kmod-mhi-pci-generic kmod-qrtr-mhi kmod-usb-net-qmi-wwan kmod-usb-net-cdc-mbim kmod-usb-net-cdc-ncm kmod-qcom-qmi-helpers luci-proto-modemmanager luci-proto-qmi luci-proto-mbim uqmi libqmi qmi-utils parted gdisk blkid fdisk cfdisk smartmontools kmod-phy-broadcom "

# rootfs unpacked = 165 MiB, squashfs = 46 MiB -> 288 MiB partition
sed -i 's/^CONFIG_TARGET_ROOTFS_PARTSIZE=.*/CONFIG_TARGET_ROOTFS_PARTSIZE=288/' .config 2>/dev/null || \
  echo "CONFIG_TARGET_ROOTFS_PARTSIZE=288" >> .config
echo "[*] Building OpenWrt 25.12.5 x86-64 UEFI image (rootfs 288 MB)..."
make image PROFILE=generic PACKAGES="$PACKAGES" FILES=files/ BIN_DIR=bin IGNORE_ERRORS=m -j1 \
  CONFIG_SQUASHFS_COMPRESSION=zstd \
  CONFIG_SQUASHFS_ZSTD_LEVEL=19 \
  CONFIG_SQUASHFS_ZSTD_THREADS=1 \
  2>&1 | tee "$BASE/build_$(date +%Y%m%d_%H%M%S).log"

echo "[*] Build done"
ls -la bin/targets/x86/64/*.img* 2>/dev/null || ls -la bin/