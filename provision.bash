#!/bin/bash
#
# Provisioning script for vagrant.

main() {
    if [[ $EUID != 0 ]]; then
        msg "--> provision.bash as_user"
        as_user
        msg "<-- provision.bash as_user"
        return
    fi

    msg "--> provision.bash as_root"
    as_root
    msg "<-- provision.bash as_root"

    set_vagrant_user

    su $VAGRANT_USER -c "$(printf '%q ' "$0" "$@")"
}

as_root() {
    is_vbox && vbox_preinstall

    install_packages

    is_lxc && lxc_postinstall
    common_postinstall
}

vbox_preinstall() {
    # If the host has moved between networks, sometimes DNS needs to be
    # reconnected.
    /etc/init.d/networking restart
}

common_postinstall() {
    # Set the timezone
    ln -sfn /usr/share/zoneinfo/EST5EDT /etc/localtime
}

lxc_postinstall() {
    declare uid gid

    # Make the vagrant uid/gid match the host user
    # so the bind-mounted source area works properly.
    read uid gid <<<"$(stat -c '%u %g' /home/vagrant/src/.)"
    if [[ ! -n $uid ]]; then
        die "Couldn't read uid/gid for vagrant user"
    fi

    if [[ $(id -u vagrant) != $uid || $(id -g vagrant) != $gid ]]; then
        # usermod/userdel doesn't work when logged in
        sed -i '/vagrant/d' /etc/passwd /etc/shadow
        groupmod -g $gid vagrant
        useradd -u $uid -g vagrant -G sudo -s /bin/bash vagrant \
            -p "$(perl -e "print crypt('vagrant', 'AG')")"
        find /home/vagrant -xdev -print0 | xargs -0r chown $uid:$gid
        chown $uid:$gid /tmp/vagrant-shell
    fi
}

install_packages() {
    declare -a packages
    packages+=( python-software-properties ) # for add-apt-repository
    packages+=( curl rsync )
    packages+=( python-pip python-virtualenv python-dev )
    packages+=( ruby-dev bundler )
    packages+=( mercurial git )
    packages+=( sudo ssh )
    packages+=( make gcc g++ binutils )
    packages+=( inotify-tools ) # inotifywait
    packages+=( nodejs ) # for jekyll

    # Don't install extra stuff
    cat > /etc/apt/apt.conf.d/99vagrant <<EOT
APT::Install-Recommends "false";
APT::Install-Suggests "false";
EOT

    # This should prevent apt-get install/upgrade from asking ANY questions
    export DEBIAN_FRONTEND=noninteractive

    apt-get update
    apt-get install -y "${packages[@]}"
    apt-get upgrade -y "${packages[@]}"
}

as_user() {
    cd ~

    if [[ $PWD == */vagrant ]]; then
        rm -f .profile
        cp -avf src/vagrant/skel/. .
        cp -nv .ssh/{id_rsa.pub,authorized_keys}
        chmod -R go-rw .ssh
        source .bash_profile
    fi

    user_virtualenv
    user_gems
}

user_virtualenv() {
    cd ~

    if [[ ! -d env ]]; then
        virtualenv env
    fi
    source env/bin/activate

    if [[ -f src/requirements.txt ]]; then
        PYTHONUNBUFFERED=1 pip install -r src/requirements.txt
    fi
}

user_gems() {
    cd ~

    if ! grep -q GEM_HOME env/bin/activate; then
        echo 'export GEM_HOME="$VIRTUAL_ENV/ruby" PATH="$VIRTUAL_ENV/ruby/bin:$PATH"' >> env/bin/activate
    fi
    source env/bin/activate

    if [[ -f src/Gemfile ]]; then
        cd src
        gem update
        bundle install
    fi
}

msg() {
    echo "$*"
}

die() {
    echo "$*"
    exit 1
}

is_lxc() {
    if [[ ! -d /home/vagrant ]]; then
        echo "is_lxc: running outside vagrant?" >&2
        return 1
    fi
    # https://www.redhat.com/archives/virt-tools-list/2013-April/msg00117.html
    sudo grep -q container=lxc /proc/1/environ
    eval "is_lxc() { return $?; }"
    is_lxc
}

is_vbox() {
    if [[ ! -d /home/vagrant ]]; then
        echo "is_vbox: running outside vagrant?" >&2
        return 1
    fi
    which dmidecode &>/dev/null || sudo apt-get install -y dmidecode
    sudo dmidecode 2>/dev/null | grep -q VirtualBox
    eval "is_vbox() { return $?; }"
    is_vbox
}

set_vagrant_user() {
    if [[ -z $VAGRANT_USER ]]; then
        if is_lxc || is_vbox || getent passwd vagrant >/dev/null; then
            VAGRANT_USER=vagrant
        else
            VAGRANT_USER=$(stat -c %U "$(type -P "$0")")
        fi
    fi
    if ! getent passwd "$VAGRANT_USER" >/dev/null; then
        die "Invalid VAGRANT_USER=$VAGRANT_USER"
    fi
}

#######################################################################
#
# RUN MAIN only if not sourced into another script
#
#######################################################################

case ${0##*/} in
    provision.bash|vagrant-shell) main "$@" ;;
esac
