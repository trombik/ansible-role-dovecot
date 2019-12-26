import os

import testinfra
import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def get_service_name(host):
    if host.system_info.distribution == 'freebsd':
        return 'openssh'
    if host.system_info.distribution == 'openbsd':
        return 'sshd'
    elif host.system_info.distribution == 'ubuntu':
        return 'sshd'
    elif host.system_info.distribution == 'centos':
        return 'sshd'
    raise NameError('Unknown distribution')


def get_ansible_vars(host):
    return host.ansible.get_variables()


def get_ansible_facts(host):
    return host.ansible('setup')['ansible_facts']


def get_ping_target(host):
    ansible_vars = get_ansible_vars(host)
    if ansible_vars['inventory_hostname'] == 'server1':
        return 'client1' if is_docker(host) else '192.168.21.100'
    elif ansible_vars['inventory_hostname'] == 'client1':
        return 'server1' if is_docker(host) else '192.168.21.200'
    else:
        raise NameError(
                "Unknown host `%s`" % ansible_vars['inventory_hostname']
              )


def read_remote_file(host, filename):
    f = host.file(filename)
    assert f.exists
    assert f.content is not None
    return f.content.decode('utf-8')


def is_docker(host):
    ansible_facts = get_ansible_facts(host)
    if 'ansible_virtualization_type' in ansible_facts:
        if ansible_facts['ansible_virtualization_type'] == 'docker':
            return True
    return False


def read_digest(host, filename):
    uri = "ansible://client1?ansible_inventory=%s" \
            % os.environ['MOLECULE_INVENTORY_FILE']
    client1 = host.get_host(uri)
    return read_remote_file(client1, filename)


def get_listen_ports(host):
    if host.system_info.distribution == 'freebsd':
        return [22, 10022]
    if host.system_info.distribution == 'openbsd':
        return [22, 10022]
    elif host.system_info.distribution == 'ubuntu':
        return [22, 10022]
    elif host.system_info.distribution == 'centos':
        return [22]
    raise NameError('Unknown distribution')


def test_hosts_file(host):
    f = host.file('/etc/hosts')

    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root' or f.group == 'wheel'


def test_icmp_from_client(host):
    ansible_vars = get_ansible_vars(host)
    if ansible_vars['inventory_hostname'] == 'client1':
        target = get_ping_target(host)
        cmd = host.run("ping -c 1 -q %s" % target)

        assert cmd.succeeded


def test_icmp_from_server(host):
    ansible_vars = get_ansible_vars(host)
    if ansible_vars['inventory_hostname'] == 'server1':
        target = get_ping_target(host)
        cmd = host.run("ping -c 1 -q %s" % target)

        assert cmd.succeeded


def test_service(host):
    s = host.service(get_service_name(host))

    # XXX in docker, host.service() does not work
    if not is_docker(host):
        assert s.is_running
        assert s.is_enabled


def test_port(host):
    ports = get_listen_ports(host)

    for p in ports:
        assert host.socket("tcp://:::%d" % p).is_listening


def test_find_digest1_on_client(host):
    ansible_vars = get_ansible_vars(host)
    if ansible_vars['inventory_hostname'] == 'client1':
        f = host.file('/tmp/digest1')

        assert f.exists


def test_find_digest2_on_client(host):
    ansible_vars = get_ansible_vars(host)
    if ansible_vars['inventory_hostname'] == 'client1':
        f = host.file('/tmp/digest2')

        assert f.exists
