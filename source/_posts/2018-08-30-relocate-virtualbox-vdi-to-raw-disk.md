---
title: Relocating a VirtualBox .vdi disk file to an external SSD (raw disk)
tags:
    - ssh
    - yubikey
    - security
    - macos
    - virtualbox
categories:
    - virtualization
draft: yes
---

In the financial world (anything enterprise-y really) everything runs in Windows.

More and more custom single-purpose applications run on


I bought a license for Windows 10 Pro and installed it in a VirtualBox VM.



The simpler thing would be to just reinstall Windows on the new __ disk


Convert .vdi to RAW disk image file

```bash
VBoxManage clonehd --format RAW debian.vdi debian.img
```


Use [Etcher](https://etcher.io) to "burn" the raw image file into the external SSD.

It will ask you a couple of times before ___ 


Create a VirtualBox

http://mattfife.com/?p=2302

```bash
diskutil list
```

To double check, run the

```bash
diskutil info /dev/disk#
```

Take note of the disk number since we will be using it a lot.


Unmount the disk / partitions in case they were automatically mounted by the system, use Disk Uility in macOS.




```bash
VBoxManage internalcommands createrawvmdk -filename "win10.vmdk" -rawdisk /dev/disk#
```

This will create a small file called `win10.vmdk` which is simply a pointer to the physical disk location.

You can then use this `.vmdk` file and attach it to a VM in VirtualBox.

you can either replace the hard drive in your VM or create a new VM.

Attach the VMDK to a VM
Create a new VM and attach


Bug: 

I'm not

The simplest fix is to allow _any_ user to access the device:

```bash
sudo chmod 777 /dev/disk#
```



Resize 

The original .vdi file might not have been as big as the 

https://www.disk-partition.com/windows-10/windows-10-disk-management-0528.html