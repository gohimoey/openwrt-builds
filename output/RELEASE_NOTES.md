# OpenWrt 25.12.5 x86-64 All-in-One

**Release:** 25.12.5
**Target:** x86/64 (Generic)
**Rootfs:** 288 MB / ~208.1 MiB installed
**Packages:** 453 installed
**Kernel:** 6.12.94

## Download

| File | Size | SHA256 |
|------|------|--------|
| openwrt-25.12.5-x86-64-generic-ext4-combined-efi.img.gz | 83M | 1a1cb0bc4c2aa35b1957ce9128962e39831253f06abf012d13a8628ce8bddea4 |
| openwrt-25.12.5-x86-64-generic-ext4-combined.img.gz | 82M | d21beef1d3a65ca18ca91e29beb9a6dfea547b9c2e0b18e51cd9b5708bd354dd |
| openwrt-25.12.5-x86-64-generic-squashfs-combined-efi.img.gz | 69M | 69dd7a8ac26ecf76991371bfa029a7820e67a402dce86b4b5873ea3714f91b8f |
| openwrt-25.12.5-x86-64-generic-squashfs-combined.img.gz | 69M | 47e28d2f892e21875eab0085bb33596d5238dbaf7c1ec5c1e06a34b1e24b0fc8 |

## Flash recommendation
- **UEFI (most PC/NAS):** squashfs-combined-efi
- **Legacy BIOS:** squashfs-combined
- **Writable rootfs (ext4):** ext4-combined-efi / ext4-combined

## Included features
- LuCI web interface (SSL + OpenWrt theme)
- VPN / proxy: OpenClash, Passwall, Tailscale
- Ad-blocking: AdGuard Home
- WAN/load-balance: MWAN3, SQM QoS, BanIP
- Network protocols: ModemManager, QMI, MBIM, UQMI, PPPoE
- File sharing: Samba 4
- Utilities: Aria2, Filebrowser, Watchcat, WOL, iperf3
- Storage: ext4, NTFS3, exFAT, F2FS, Btrfs, HFS+
- Wireless: MT76 (MT7921/MT7922/MT7615/MT7915/MT7916/MT76x2/MT76x02), ATH9K/ATH10K, IWLWiFi
- USB Ethernet: RTL8152, ASIX AX88179, CDC NCM/MBIM/Ether, QMI
- Shell tools: bash, tmux, nano, htop, curl

## Verification
sha256sum -c *.sha256sum

## Notes
- Built with all OpenWrt feed packages mirrored locally (APK).
- CONFIG_SIGNATURE_CHECK disabled because local mirror index is unsigned.
- --force-no-chroot used in container builder environment.
