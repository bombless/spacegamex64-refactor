mkdir esp\EFI\BOOT
copy SpaceGame.efi esp\EFI\BOOT\BOOTX64.EFI
qemu-system-x86_64 -bios DEBUGX64_OVMF.fd -drive format=raw,file=fat:rw:./esp
