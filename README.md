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
| `dovecot_extra_packages` | List of extra packages to install | `[]` |
| `dovecot_conf_dir` | Path to directory where `dovecot.conf` resides | `{{ __dovecot_conf_dir }}` |
| `dovecot_confd_dir` | Path to `conf.d` | `{{ dovecot_conf_dir }}/conf.d` |
| `dovecot_conf_file` | Path to `dovecot.conf(5)` | `{{ __dovecot_conf_dir }}/dovecot.conf` |
| `dovecot_flags` | Additional flags to `dovecot` daemon | `""` |
| `dovecot_base_dir` | `base_dir` in `dovecot.conf(5)` | `{{ __dovecot_base_dir }}` |
| `dovecot_config` | Content of `dovecot.conf(5)` | `""` |
| `dovecot_config_fragments` | List of dict of additional configuration file fragments. See below | `[]` |
| `dovecot_login_class` | login class to append to `login.conf(5)`. Used only when `ansible_os_family` is `OpenBSD` | `{{ __dovecot_login_class }}` |
| `dovecot_extra_groups` | Additional list of groups to add `dovecot` user | `[]` |
| `dovecot_include_role_x509_certificate` | Include `trombik.x509-certificate` role during the play | `no` |

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

## Debian

| Variable | Default |
|----------|---------|
| `__dovecot_user` | `dovecot` |
| `__dovecot_group` | `dovecot` |
| `__dovecot_conf_dir` | `/etc/dovecot` |
| `__dovecot_service` | `dovecot` |
| `__dovecot_package` | `dovecot-core` |
| `__dovecot_base_dir` | `/var/run/dovecot` |
| `__dovecot_login_class` | `""` |

## TLS/SSL support

The role implements TLS/SSL support by importing `trombik.x509-certificate`
during the play.
[`trombik.x509-certificate`](https://github.com/trombik/ansible-role-x509-certificate)
must be available by listing it in `requirements.yml`, then set
`dovecot_include_role_x509_certificate` to `yes`.

See
[tests/serverspec/default.yml](tests/serverspec/default.yml) for an example.

# Dependencies

None

# Example Playbook

```yaml
- hosts: localhost
  roles:
    - ansible-role-dovecot
  vars:
    x509_certificate_debug_log: yes
    x509_certificate:
      - name: dovecot
        state: present
        public:
          path: "{{ dovecot_conf_dir }}/ssl/dovecot_pub.pem"
          owner: "{{ dovecot_user }}"
          key: |
            -----BEGIN CERTIFICATE-----
            MIIFjTCCA3WgAwIBAgIJAOWEMp5KrvqIMA0GCSqGSIb3DQEBCwUAMF0xCzAJBgNV
            BAYTAlRIMRAwDgYDVQQIDAdCYW5na29rMSEwHwYDVQQKDBhJbnRlcm5ldCBXaWRn
            aXRzIFB0eSBMdGQxGTAXBgNVBAMMEGEubXgudHJvbWJpay5vcmcwHhcNMTcxMjAx
            MDM1NzA5WhcNMTgxMjAxMDM1NzA5WjBdMQswCQYDVQQGEwJUSDEQMA4GA1UECAwH
            QmFuZ2tvazEhMB8GA1UECgwYSW50ZXJuZXQgV2lkZ2l0cyBQdHkgTHRkMRkwFwYD
            VQQDDBBhLm14LnRyb21iaWsub3JnMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIIC
            CgKCAgEAsqn3qdkjpvXn3vWIdPCCwGCQdaPhOxiyR0lVd3HfZOZpUM9u2Y+alXZx
            exaOeMVIc8Ucazz49e1cgAYW+j4Y7roortcWpGJxUqY0LL3i4rBXJMsIjMDQ8gC9
            ymC4ktPelzxWX1evs1j35ZJXynYTVYztLkSLnJuVjqUqjEj/EhjqQFqgRKlhKtED
            9JeNM2NGTihYe4o2pTNoosNSsDsvy6liBi2Soko3D0XFkqD7hgCBn6NwJuzCvLQr
            ypftGS7Bb1vsq9mEXSDeGZE1zZ170CtJ5/bKfsj66ecUBkt7X4qiFxos8vwb+k9M
            WHgTtwipYrXr214aymdEP5t8ze0z6MhFJQU9FYfJ/VqaxV6ug+NH995uKaalY3np
            X1vPANODi33wVIze0AiAYCu/bimfw4imG5AiTe7yJZLTa7tUcJ+HgHyZ6kV1Z4MM
            CvqqMRKR//yELwFunJ8smDneKV5KnEB1aiH2RcmhplXIcrBtNIGnoOPH84SNJ/Hx
            ji3H5meQLYQ0hv5NUXSHDr0bykrHvk5s1fBxG2/CORrMcwTY3dN+1oGDn7o56Wzl
            nQ5VGYHWhVyBbfx2utSFeyMgDFrO/NKQBo8jS1UrUW5smYWcCV3LPo+dw3SShIEc
            Y/kmbiljQ9+989oLQMvWbYunPzOUrMJUL6XB6We+nuEWnWRDCncCAwEAAaNQME4w
            HQYDVR0OBBYEFBdZboL9VDGD0csUCItPSFX+DSQzMB8GA1UdIwQYMBaAFBdZboL9
            VDGD0csUCItPSFX+DSQzMAwGA1UdEwQFMAMBAf8wDQYJKoZIhvcNAQELBQADggIB
            AGiG1DxpTue9Ji9VnkDmrf1uMWi+Xv+adGBjETR3ojR6H8VaMhPZUrGAcTeB3C8h
            C6mS0uTm6gAthPP0b25GgYRuZn2TSsWaURH6fXJJISrvZVNfY7CrN7eyK19BYSf+
            31KREZOftm/0q8E+dpmUxKXSgvn4NmXG5TD7gOU9d2v9n9RtyNVrXyOWVWMcP73u
            StVHHONGwQcm5E7oyQsVcmqKziy7KZxMQwCQ13qzfwlALKDJN19uA/cBBySov05y
            NxNHKnhXnzxI57kmm+J7qy7D+XFzEsZZmZVS5J9mOOos19EHXx/qepRtPdxtJgFO
            HJV+4tR7gtMCTC84ZkvRC8mUKCcbkzVniutKzdKSZ0uUeDHpAHp/Sv3+5qaevZ9D
            2CcbxfqtSfEXr6VHBnBacLBF25P/d3gPN0TqXpR9fhhL1Q8LPW2VrEH9zfLDUDRA
            argrFehyERw1WvSIhnz33kicpGC11viN6ITdAChNALttnBYOOPWaBSJL0HCw4HfN
            DuUckexsq3zK5oNCCc3bua7tJCB/Jv0lgMZt7sRR7t2UY7Dy/EZH5Zfk9FxUKY/C
            98XdGs+SkGrSHyXaHBmcUfFtUW7JfYEcAFrIWLV6E7e1BBjExn53Z97xZgwOvq1x
            m0f30I/wnrEVBZwTF/pl5dDLq3a3Pm0kEIcZkzwXve4+
            -----END CERTIFICATE-----
        secret:
          path: "{{ dovecot_conf_dir }}/ssl/dovecot_key.pem"
          owner: "{{ dovecot_user }}"
          key: |
            -----BEGIN RSA PRIVATE KEY-----
            MIIJKQIBAAKCAgEAsqn3qdkjpvXn3vWIdPCCwGCQdaPhOxiyR0lVd3HfZOZpUM9u
            2Y+alXZxexaOeMVIc8Ucazz49e1cgAYW+j4Y7roortcWpGJxUqY0LL3i4rBXJMsI
            jMDQ8gC9ymC4ktPelzxWX1evs1j35ZJXynYTVYztLkSLnJuVjqUqjEj/EhjqQFqg
            RKlhKtED9JeNM2NGTihYe4o2pTNoosNSsDsvy6liBi2Soko3D0XFkqD7hgCBn6Nw
            JuzCvLQrypftGS7Bb1vsq9mEXSDeGZE1zZ170CtJ5/bKfsj66ecUBkt7X4qiFxos
            8vwb+k9MWHgTtwipYrXr214aymdEP5t8ze0z6MhFJQU9FYfJ/VqaxV6ug+NH995u
            KaalY3npX1vPANODi33wVIze0AiAYCu/bimfw4imG5AiTe7yJZLTa7tUcJ+HgHyZ
            6kV1Z4MMCvqqMRKR//yELwFunJ8smDneKV5KnEB1aiH2RcmhplXIcrBtNIGnoOPH
            84SNJ/Hxji3H5meQLYQ0hv5NUXSHDr0bykrHvk5s1fBxG2/CORrMcwTY3dN+1oGD
            n7o56WzlnQ5VGYHWhVyBbfx2utSFeyMgDFrO/NKQBo8jS1UrUW5smYWcCV3LPo+d
            w3SShIEcY/kmbiljQ9+989oLQMvWbYunPzOUrMJUL6XB6We+nuEWnWRDCncCAwEA
            AQKCAgAmvRfIKh7C2trVyyM1R9jx4X4xI8F4UNiHAG2ZooUvmY4ISZHddnesJKxi
            ZfeqVAxrnbeVwPiySi8eSzO8Oq6pRJABqP1t0zKDGyqA8QM658VdYvCNpFkpv+Nm
            +CXNIEdJP3ny3k5ocsf9bQfADG4QxKfAungTEuEQtttM4576y5AvN/c8LAW3hO54
            oEurcsERvUnCL6u9kjID6JoLQCoS3L02XbdHnRPnKde2/VTML1vrw0JUDk4DIIXG
            Pb7ZEPw8KxBcCqPalX/Sx1uFI7pu3pP9ydMKPoW5JbN/0eoEQ0j1/WT1ophmY79I
            B3Eu5J/lmVB0lij07gMsT4h2FhKE79N830aVMwZqp1JpeFarSd+y/uHWE1/qj4Px
            16+tsdtNYftl5u9vuOz0Bmw6lszKT+Y6GnzTzEpgvbi5oSqT50va6sb+ScvVx1Vo
            ZgMcppOuSQhndYRT4+VuZD8dmBfR8tkINrlIURSIJzACLLV5aU9PtBkxFS4QIAjA
            1JzUJoUUS26gGI/fO69ZGZQdYX/eACan4C82JJcS3HBBwmPvYS3T/e9uV5G4e/q4
            im1zNxRTOaWDe6mK3kLOVncAPKydYba47kG9PCMTM6Vf5nKww9C7p/sAMekldRdq
            E8fRDBApEltYN50ykGvLhTQGfAEyODi2C6rS1XP5uiRhADF5kQKCAQEA4kkAaBhE
            oAs4vO3kUOEaTCnn4j4kqSvr2Rgk1++cEheUk5nrmKUeMz6+ViInguVvfI+yyJcN
            0wLUVQ2mHQc4iMa3LffIyZ923d9L7e/Z3H5tCgbKEeKpFI4OPm7IRmGuK9SwQrUm
            Dq2DRWFTVgCVZ2QWS+r7ECST1+rdbRNYa1rslIOHAwqazMIbNFFEWvXJsc2cRiBs
            WSaCdePdPl53Gv7pphhQ7YmvciRLc/ofR9FrW/gAXta+CJ/f22+C4FALE6CT+0KV
            fonb7r9144WEkxmJV4HAle5SkUxTf4tUGypkPFrbu3bpc36iQu37SDtX/UXFk75n
            gvJXy/WHCAycewKCAQEAyiAW3051kuYxEuafWx9RS6/T+6sMSFjTDIpwdcsMF3tT
            0OvwyORcio1Q641556F7ogCuvR0+JK/rmJ3A1AUjTSDOFn+qfsm7sdYYvcHASHt4
            xqCyHY/jrw8O+m9h1AnA4r5J0ffRdulzGAnZjF6acMLbRvUgQyIvwPEXofDkixWt
            BRz+REKJewInXb+NcC0NASL0N+7tEK1g5jZoi3cEu4EqS05DCRM9FWV3ai6hOHqX
            0p68+IM5qAQT9fu4k6qKcGwH8cMskApbZjpjhO2jQ82kMyAUXUQco2AYWCKQNAht
            cmCiPrGPIL2eXxtrVi+/UuS4wVMgdgYxtsxboy9fNQKCAQEA2Ch8JvPnuip+DJwD
            Ge+uO0tcoxZR1viJ11vk9hGBuRala0oBcFNqwfERyR3fOH8LPKXYVx1Uq1lsk8Ly
            B5C6RI3utg6Y02FtHw0Lb0NLjgGHD6jkpqkqcuQwXxtcXT86LcyCg3af4C2H1GLg
            RKtSDO3jDqptIkKOqBdHZcaxE/xLOqNZ+WHL9gUGD7gB4BIilaKfwa1/UroirZL5
            6XY7uKIBeBSKWh7IZfSdzzADaYt3TuddEzt3VK3EHc4r6zMLIbinI8G7JKF0YmCq
            sKj+t7YRKHJeEdsTLJEIwjHKKhkYnz7739v7rcQuJFlJTPrDVsGrtzKPltsBW2gz
            kVDauQKCAQEAwPmGHMkhw5B2hd8dgbgSu7oxH3QdE+2KAc0itbOX5ctfKHY6uvIb
            0EQ/X8UBAD7SdMdGDVQgApLa0ii68zG8lGSfnidhNg+QXadUk8apuAn6M1k09Lht
            3rL3z+4Lbo+pUlHu1MJPf8I+mlK9GyEvPj0rcUGS/cVj5kfIElqVOJ0HRXx63dzQ
            uVpDD2RUuyan5c/jbot0VpnRi7micpS9Ne+J27/qjH2LsiPfsMa4Md4JmZLoRDO1
            Fk5eaFldzc3iwpbBtvZqU1MwFBfm8ACaAaASBqW4C5t95BVY6LyHBMaPB8Zu4IBR
            cCbZT2A0SGLpvVCVfC3LLiOXzziovNH7iQKCAQBaTZjEvb+0gY2lCIQMnM7D1TJH
            W13yc5OzqmUN3I0XFSM5umDBvO7OQ11x2FAmY1rfxi09URDzvrEUI0Flo6prKvUW
            kXOHR1+ytH2gsTeE1gRH30Oweo1U3BoFHD/e9F2PVJAuYgwoGpKAFvnLWzYFKkRT
            mR6L5TZtVP9sRIYP5N6urViAf6gzVjxl+ka6HoF4p5I+FyAuWk/ninsDwrUPUVNd
            8eRVIEZInjICg5oSahgxNnedIv0mpyXThICvgHuPgs7XoC5efx/7dAxQv/3W1xcP
            MNUO4TmsSHDnBrgFSg/czEg2sH527C4/hLPlIsNqCNKZf/MblRTrsWn823yA
            -----END RSA PRIVATE KEY-----
    dovecot_include_role_x509_certificate: true
    dovecot_extra_packages: "{% if ansible_os_family == 'Debian' %}[ 'dovecot-imapd' ]{% else %}[]{% endif %}"
    dovecot_extra_groups: "{% if ansible_os_family == 'Debian' %}[ 'nogroup' ]{% else %}[ 'nobody' ]{% endif %}"
    dovecot_config: |
      protocols = {% if ansible_os_family == 'Debian' %}imap{% else %}imaps{% endif %}

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
          disable_plaintext_auth = yes
          passdb {
            driver = {% if ansible_os_family == 'FreeBSD' or ansible_os_family == 'Debian' %}pam{% elif ansible_os_family == 'OpenBSD' %}bsdauth{% endif %}

          }
          userdb {
            driver = passwd
          }
      - name: ssl.conf
        state: present
        mode: "0640"
        content: |
          {% if ansible_os_family == 'Debian' %}
          # older dovecot complains:
          # 'imaps' protocol can no longer be specified (use protocols=imap)
          service imap-login {
            inet_listener imap {
              port = 0
            }
          }
          {% endif %}
          ssl = required
          ssl_cert = <{{ dovecot_conf_dir }}/ssl/dovecot_pub.pem
          ssl_key = <{{ dovecot_conf_dir }}/ssl/dovecot_key.pem
```

# License

```
Copyright (c) 2017 Tomoyuki Sakurai <y@trombik.org>

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

Tomoyuki Sakurai <y@trombik.org>

This README was created by [qansible](https://github.com/trombik/qansible)
