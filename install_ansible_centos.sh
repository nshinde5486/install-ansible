yum_makecache_retry() {
  tries=0
  until [ $tries -ge 5 ]
  do
    yum makecache && break
    let tries++
    sleep 1
  done
}

if [ "x$KITCHEN_LOG" = "xDEBUG" -o "x$OMNIBUS_ANSIBLE_LOG" = "xDEBUG" ]; then
  export PS4='(${BASH_SOURCE}:${LINENO}): - [${SHLVL},${BASH_SUBSHELL},$?] $ '
  set -x
fi

    export HTTP_PROXY=http://web-proxy.rose.hpecorp.net:8080
    export HTTPS_PROXY=http://web-proxy.rose.hpecorp.net:8088

    yum -y install ca-certificates nss
    yum clean all
    rm -rf /var/cache/yum
    yum_makecache_retry
    yum -y install epel-release
    yum_makecache_retry

    yum -y install python-pip PyYAML python-jinja2 python-httplib2 python-keyczar python-paramiko git
    # If python-pip install failed and setuptools exists, try that
    if [ -z "$(which pip)" -a -z "$(which easy_install)" ]; then
      yum -y install python-setuptools
      easy_install pip
    elif [ -z "$(which pip)" -a -n "$(which easy_install)" ]; then
      easy_install pip
    fi

    # Install passlib for encrypt
    yum -y groupinstall "Development tools"
    yum -y install python-devel MySQL-python sshpass && pip install pyrax pysphere boto passlib dnspython

    # Install Ansible module dependencies
    yum -y install bzip2 file findutils git gzip hg svn sudo tar which unzip xz zip libselinux-python
    [ -n "$(yum search procps-ng)" ] && yum -y install procps-ng || yum -y install procps


    mkdir /etc/ansible/
    echo -e '[local]\nlocalhost\n' > /etc/ansible/hosts
    # install ansible
    pip install ansible
    # clone the code to run the tests
    git clone https://github.com/nshinde5486/ansible-openswitch-tests.git
