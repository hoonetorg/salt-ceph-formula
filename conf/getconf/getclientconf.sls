include:
  - .getadminkeyring
  - .getauthkeyringfiles

ceph_conf_getconf_getclientconf__connect_keyrings:
  cmd.run:
    - name: echo ceph_conf_getconf_getclientconf__connect_keyrings
    - unless: true
    - require:
      - cmd: ceph_conf_getconf_getadminkeyring_available
    - require_in:
      - file: ceph_conf_getconf_getauthkeyringfiles__file_/etc/ceph
