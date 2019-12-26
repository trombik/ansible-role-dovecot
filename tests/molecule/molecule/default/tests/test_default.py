import os

import testinfra
import testinfra.utils.ansible_runner
import imaplib

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def get_imap_object(host):
    if is_docker(host):
        host = '127.0.0.1'
        port = 1143
    else:
        host = '192.168.21.200'
        port = 143
    return imaplib.IMAP4(host, port)


def get_service_name(host):
    if host.system_info.distribution == 'freebsd':
        return 'dovecot'
    if host.system_info.distribution == 'openbsd':
        return 'dovecot'
    elif host.system_info.distribution == 'ubuntu':
        return 'dovecot'
    elif host.system_info.distribution == 'centos':
        return 'dovecot'
    raise NameError('Unknown distribution')


def get_ansible_vars(host):
    return host.ansible.get_variables()


def get_ansible_facts(host):
    return host.ansible('setup')['ansible_facts']


def is_docker(host):
    ansible_facts = get_ansible_facts(host)
    if 'ansible_virtualization_type' in ansible_facts:
        if ansible_facts['ansible_virtualization_type'] == 'docker':
            return True
    return False


def test_service(host):
    s = host.service(get_service_name(host))

    # use sudo as pid file has strict permission on FreeBSD
    with host.sudo():
        assert s.is_running
        assert s.is_enabled


def test_login(host):
    user = 'john@example.org'
    password = 'PassWord'

    imap = get_imap_object(host)
    assert imap.login(user, password)
