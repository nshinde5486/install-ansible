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

if [ ! $(which ansible-playbook) ]; then
  if [ -f /etc/centos-release ] || [ -f /etc/redhat-release ] || [ -f /etc/oracle-release ] || [ -f /etc/system-release ]
  then
    export HTTP_PROXY=http://web-proxy.rose.hpecorp.net:8080
    export HTTPS_PROXY=http://web-proxy.rose.hpecorp.net:8088

    yum -y install ca-certificates nss
    yum clean all
    rm -rf /var/cache/yum
    yum_makecache_retry
    yum -y install epel-release
    yum_makecache_retry

    yum -y install python-pip PyYAML python-jinja2 python-httplib2 python-keyczar python-paramiko git
    if [ -z "$(which pip)" -a -z "$(which easy_install)" ]; then
      yum -y install python-setuptools
      easy_install pip
    elif [ -z "$(which pip)" -a -n "$(which easy_install)" ]; then
      easy_install pip
    fi

    yum -y groupinstall "Development tools"
    yum -y install python-devel MySQL-python sshpass && pip install pyrax pysphere boto passlib dnspython

    yum -y install bzip2 file findutils git gzip hg svn sudo tar which unzip xz zip libselinux-python
    [ -n "$(yum search procps-ng)" ] && yum -y install procps-ng || yum -y install procps
  fi

  if [ -f /etc/debian_version ] || [ grep -qi ubuntu /etc/lsb-release ] || [grep -qi ubuntu /etc/os-release]
  then
    export http_proxy=http://web-proxy.rose.hpecorp.net:8080
    export https_proxy=http://web-proxy.rose.hpecorp.net:8088

    apt-get update

    # Install required Python libs and pip
    apt-get install -y  python-pip python-yaml python-jinja2 python-httplib2 python-paramiko python-pkg-resources
    [ -n "$( apt-cache search python-keyczar )" ] && apt-get install -y  python-keyczar
    if ! apt-get install -y git ; then
      apt-get install -y git-core
    fi
    # If python-pip install failed and setuptools exists, try that
    if [ -z "$(which pip)" -a -z "$(which easy_install)" ]; then
      apt-get -y install python-setuptools
      easy_install pip
    elif [ -z "$(which pip)" -a -n "$(which easy_install)" ]; then
      easy_install pip
    fi
    # If python-keyczar apt package does not exist, use pip
    [ -z "$( apt-cache search python-keyczar )" ] && sudo pip install python-keyczar

    # Install passlib for encrypt
    apt-get install -y build-essential
    apt-get install -y python-all-dev python-mysqldb sshpass && pip install pyrax pysphere boto passlib dnspython

    # Install Ansible module dependencies
    apt-get install -y bzip2 file findutils git gzip mercurial procps subversion sudo tar debianutils unzip xz-utils zip python-selinux
  fi

  mkdir /etc/ansible/
  echo -e '[local]\nlocalhost\n' > /etc/ansible/hosts

  # source install to get latest ansible
  git clone https://github.com/ansible/ansible.git --recursive --branch stable-2.1
  make install
  # clone the code to run the tests
  git clone https://github.com/nshinde5486/ansible-openswitch-tests.git

fi

