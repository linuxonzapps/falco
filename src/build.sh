#!/bin/bash
set -e -o pipefail
read -ra arr <<< "$@"
version=${arr[1]}
trap 0 1 2 ERR
# Extract DISTRO details for tagging
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO="$ID-$VERSION_ID"
    if [ "$VERSION_CODENAME" != "" ]; then
        DISTRO="$ID-$VERSION_CODENAME"
    fi
fi
current_dir="$PWD"
echo $DISTRO > .distro_zab.txt
apt update; apt install sudo git rpm -y
# Clone linux-on-ibm-z to keep it current
git clone https://github.com/linux-on-ibm-z/scripts.git /tmp/linux-on-ibm-z
# Remove insmod and rmmod as they are not needed and build didtribution packages
sed -i '/insmod/d; /rmmod/d; /Falco build completed/a \    make package' /tmp/linux-on-ibm-z-scripts/Falco/${version}/build_falco.sh
# Build Binary, Debian and RPM packages
bash /tmp/linux-on-ibm-z-scripts/Falco/${version}/build_falco.sh -y
# Move generated Binary, Debian and RPM packages to current_dir
mv ${current_dir}/falco/build/falco-${version}-s390x.tar.gz ${current_dir}/falco-${version}-linux-s390x.tar.gz
mv ${current_dir}/falco/build/falco-${version}-s390x.deb ${current_dir}/falco-${version}-linux-s390x.deb
mv ${current_dir}/falco/build/falco-${version}-s390x.rpm ${current_dir}/falco-${version}-linux-s390x.rpm
exit 0
