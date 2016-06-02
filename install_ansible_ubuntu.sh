# running this shell script will transform your vm into controm machine

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

    mkdir /etc/ansible/
    echo -e '[local]\nlocalhost\n' > /etc/ansible/hosts

    # source install to get latest ansible
    git clone https://github.com/ansible/ansible.git --recursive --branch stable-2.1
    sudo make install
    # clone the code to run the tests
    git clone https://github.com/nshinde5486/ansible-openswitch-tests.git
