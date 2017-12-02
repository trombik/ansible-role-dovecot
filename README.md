# ansible-role-dovecot

Configures `dovecot`.

# Requirements

None

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `dovecot_user` | User name of `dovecot` | `{{ __dovecot_user }}` |
| `dovecot_group` | Group name of `dovecot` | `{{ __dovecot_group }}` |
| `dovecot_service` | Service name of `dovecot` | `{{ __dovecot_service }}` |
| `dovecot_package` | Package name of `dovecot` | `{{ __dovecot_package }}` |
| `dovecot_conf_dir` | Path to directory where `dovecot.conf` resides | `{{ __dovecot_conf_dir }}` |
| `dovecot_confd_dir` | Path to `conf.d` | `{{ dovecot_conf_dir }}/conf.d` |
| `dovecot_conf_file` | Path to `dovecot.conf(5)` | `{{ __dovecot_conf_dir }}/dovecot.conf` |
| `dovecot_flags` | Additional flags to `dovecot` daemon | `""` |
| `dovecot_base_dir` | `base_dir` in `dovecot.conf(5)` | `{{ __dovecot_base_dir }}` |
| `dovecot_config` | Content of `dovecot.conf(5)` | `""` |
| `dovecot_config_fragments` | List of dict of additional configuration file fragments. See below | `[]` |
| `dovecot_login_class` | login class to append to `login.conf(5)`. Used only when `ansible_os_family` is `OpenBSD` | `{{ __dovecot_login_class }}` |
| `dovecot_extra_groups` | Additional list of groups to add `dovecot` user | `[]` |

## `dovecot_config_fragments`

This variable is a list of dict of additional configuration file fragments
under `dovecot_confd_dir`.

| Key | Description | Mandatory? |
|-----|-------------|------------|
| `name` | File name | yes |
| `state` | Either `absent` or `present` | yes |
| `content` | The content of the file | yes |
| `mode` | File mode | no |
| `owner` | File owner | no |
| `group` | File group | no |

## FreeBSD

| Variable | Default |
|----------|---------|
| `__dovecot_user` | `dovecot` |
| `__dovecot_group` | `dovecot` |
| `__dovecot_conf_dir` | `/usr/local/etc/dovecot` |
| `__dovecot_service` | `dovecot` |
| `__dovecot_package` | `mail/dovecot` |
| `__dovecot_base_dir` | `/var/run/dovecot` |
| `__dovecot_login_class` | `""` |

## OpenBSD

| Variable | Default |
|----------|---------|
| `__dovecot_user` | `_dovecot` |
| `__dovecot_group` | `_dovecot` |
| `__dovecot_conf_dir` | `/etc/dovecot` |
| `__dovecot_service` | `dovecot` |
| `__dovecot_package` | `dovecot` |
| `__dovecot_base_dir` | `/var/run/dovecot` |
| `__dovecot_login_class` | see below |

```
dovecot:\
  :openfiles-cur=512:\
  :openfiles-max=2048:\
  :tc=daemon:
```

# Dependencies

None

# Example Playbook

```yaml
- hosts: localhost
  roles:
    - ansible-role-dovecot
  vars:
    dovecot_extra_groups:
      - nobody
    dovecot_config: |
      protocols = imap
      listen = *
      base_dir = "{{ dovecot_base_dir }}"
      {% for i in dovecot_config_fragments %}
      {% if i.state == 'present' %}
      !include {{ dovecot_confd_dir }}/{{ i.name }}
      {% endif %}
      {% endfor %}

    dovecot_config_fragments:
      - name: foo.conf
        state: absent
      - name: auth.conf
        state: present
        mode: "0640"
        content: |
          disable_plaintext_auth = no
          passdb {
            driver = {% if ansible_os_family == 'FreeBSD' %}pam{% elif ansible_os_family == 'OpenBSD' %}bsdauth{% endif %}

          }
          userdb {
            driver = passwd
          }
```

# License

```
Copyright (c) 2017 Tomoyuki Sakurai <tomoyukis@reallyenglish.com>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
```

# Author Information

Tomoyuki Sakurai <tomoyukis@reallyenglish.com>

This README was created by [qansible](https://github.com/trombik/qansible)
