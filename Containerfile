# Multi-stage build
ARG FEDORA_MAJOR_VERSION=37

## Build ublue-os-base
FROM quay.io/fedora-ostree-desktops/silverblue:${FEDORA_MAJOR_VERSION}
# See https://pagure.io/releng/issue/11047 for final location

# Add Vanilla First Setup
RUN wget https://copr.fedorainfracloud.org/coprs/ublue-os/vanilla-first-setup/repo/fedora-$(rpm -E %fedora)/ublue-os-vanilla-first-setup-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_ublue-os-vanilla-first-setup.repo

COPY etc /etc

COPY ublue-firstboot /usr/bin

RUN rpm-ostree override remove firefox firefox-langpacks && \
    rpm-ostree install distrobox gnome-tweaks just vte291-gtk4-devel vanilla-first-setup \
    tailscale virt-manager virt-install wireguard-tools openssl virt-viewer \
    libvirt-daemon-config-network libvirt-daemon-kvm qemu-kvm && \
    sed -i 's/#AutomaticUpdatePolicy.*/AutomaticUpdatePolicy=stage/' /etc/rpm-ostreed.conf && \
    systemctl enable rpm-ostreed-automatic.timer && \
    systemctl enable flatpak-automatic.timer && \
    systemctl enable tailscaled.service && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_ublue-os-vanilla-first-setup.repo && \
    rm -rf \
        /tmp/* \
        /var/* \
        /etc/yum.repos.d/tailscale.repo && \
    ostree container commit
