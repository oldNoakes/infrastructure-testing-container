FROM centos:7

# Install systemd -- See https://hub.docker.com/_/centos/
RUN yum -y swap -- remove fakesystemd -- install systemd systemd-libs
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /etc/systemd/system/*.wants/*; \
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*; \
rm -f /lib/systemd/system/anaconda.target.wants/*;

RUN yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7 && \
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

RUN yum install -y deltarpm

RUN yum install -y \
      wget \
      curl \
      unzip \
      tar \
      bzip2 \
      which \
      less \
      jq \
      bind-utils \
      net-tools \
      openssl \
      openssl-devel \
      findutils \
      gcc \
      libffi-devel \
      python-devel \
      sudo \
      cronie \
      libselinux \
      selinux-policy \
      libsemanage \
      policycoreutils \
      openssh-server \
      openssh-clients \
    && yum clean all

RUN curl https://bootstrap.pypa.io/get-pip.py | python
RUN pip install --no-cache-dir --upgrade pip

RUN download_url=$(curl -s https://api.github.com/repos/aelsabbahy/goss/releases/latest | jq -r ".assets[] | select(.name | test(\"goss-linux-amd64\")) | .browser_download_url") && \
    wget -nv $download_url -O /usr/local/bin/goss && \
    chmod a+x /usr/local/bin/goss

RUN groupadd -g 5555 vagrant && \
    useradd -u 5555 -g 5555 --create-home -f -1 vagrant && \
    usermod -g wheel vagrant && \
    mkdir -p /home/vagrant/.ssh && \
    chown -R vagrant:vagrant /home/vagrant/.ssh
RUN sed -i 's/^#\s*\(%wheel\s*ALL=(ALL)\s*NOPASSWD:\s*ALL\)/\1/' /etc/sudoers

EXPOSE 22
RUN systemctl enable sshd.service
CMD ["/usr/sbin/init"]

# # Files required by the Jenkins service
# COPY init.d/functions /etc/init.d/functions
# COPY profile.d/lang.sh /etc/profile.d/lang.sh

# Called by /etc/init.d/functions
# COPY sbin/consoletype /sbin/consoletype
