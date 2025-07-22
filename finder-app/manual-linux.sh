#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.15.163
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}

if [ ! -d "${OUTDIR}" ]; then
    echo "ERROR: Failed to create output directory ${OUTDIR}"
    exit 1
fi

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}

    # TODO: Add your kernel build steps here
    make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- mrproper
    make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- defconfig 
    make -j  ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- all
    make -j  ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- modules
    make -j  ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- dtbs 
fi

echo "Adding the Image in outdir"
cp "$OUTDIR/linux-stable/arch/$ARCH/boot/Image" "$OUTDIR"/


echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]

then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi

# TODO: Create necessary base directories
mkdir -p "$ROOTFS"/{bin,sbin,etc,proc,sys,usr/{bin,sbin},var,dev,lib,lib 64,home,tmp}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    # TODO:  Configure busybox
else
    cd busybox
fi

# TODO: Make and install busybox
make distclean
make defconfig 
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} 
make CONFIG_PREFIX=${OUTDIR}/rootfs/ ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install

echo "Library dependencies"
${CROSS_COMPILE}readelf -a bin/busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a bin/busybox | grep "Shared library"

# TODO: Add library dependencies to rootfs
echo "Copying BusyBox runtime dependencies into rootfs"
SYSROOT="$(${CROSS_COMPILE}gcc -print-sysroot)"

INTERP=$(${CROSS_COMPILE}readelf -a bin/busybox | \
         grep 'program interpreter' | awk '{print $NF}' | tr -d '[]')
DEPS=$(${CROSS_COMPILE}readelf -a bin/busybox | \
       grep 'Shared library'      | awk '{print $NF}' | tr -d '[]')

mkdir -p "${ROOTFS}/lib64"

cp -a "${SYSROOT}${INTERP}" "${ROOTFS}${INTERP}"

for LIB in $DEPS; do
    SRC=$(find "${SYSROOT}" -name "${LIB}" | head -n 1)
    [ -n "${SRC}" ] && cp --parents -a "${SRC}" "${ROOTFS}"
done
# TODO: Make device nodes

# TODO: Clean and build the writer utility

# TODO: Copy the finder related scripts and executables to the /home directory
# on the target rootfs

# TODO: Chown the root directory

# TODO: Create initramfs.cpio.gz
