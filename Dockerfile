# Use the base image from Quay.io for Rocky Linux 9
FROM quay.io/rockylinux/rockylinux:9

# Install systemd
RUN yum install -y systemd && \
    yum clean all && \
    rm -rf /var/cache/yum

# Setup systemd
RUN (cd /lib/systemd/system/sysinit.target.wants/; \
    for i in *; \
        do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; \
    done) && \
    rm -f /lib/systemd/system/multi-user.target.wants/* && \
    rm -f /etc/systemd/system/*.wants/* && \
    rm -f /lib/systemd/system/local-fs.target.wants/* && \
    rm -f /lib/systemd/system/sockets.target.wants/*udev* && \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl* && \
    rm -f /lib/systemd/system/basic.target.wants/* && \
    rm -f /lib/systemd/system/anaconda.target.wants/*

# Replace the default target to boot to systemd
RUN ln -sf /lib/systemd/system/multi-user.target /etc/systemd/system/default.target; dnf install git-all tar gzip zip unzip ca-certificates -y

# Mount cgroups to avoid errors
VOLUME [ "/sys/fs/cgroup" ]

RUN mkdir -p /root/.local/bin
VOLUME /root/.local/bin

# Start systemd
CMD ["/sbin/init"]
