{% set basepathsls = sls.split('.')[0] -%}
{% set environment = salt['pillar.get']('environment')-%}

ceph_conf_getconf_getadminkeyring__file_/etc/ceph:
  file.directory:
    - name: /etc/ceph
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

{% set cluster = salt['pillar.get']('cephname') -%}
{% set cluster_data = salt['pillar.get']('ceph:clusters:' + cluster ,{}) -%}
{% if cluster != '' %}

  {% set admin_keyring = '/etc/ceph/' + cluster + '.client.admin.keyring' -%}

{% if salt['cp.list_master'](environment).count('files/keys/' + basepathsls + '/' + cluster + '/' + cluster + '.client.admin.keyring') != 0 %}

ceph_conf_getconf_getadminkeyring__file_{{admin_keyring}}:
  file.managed:
    - name: {{admin_keyring}}
    - template: jinja
    - source: salt://files/keys/{{ basepathsls }}/{{cluster}}/{{cluster}}.client.admin.keyring
    - user: root
    - group: root
    - mode: '0600'
    - require:
      - file: ceph_conf_getconf_getadminkeyring__file_/etc/ceph

ceph_conf_getconf_getadminkeyring_available:
  cmd.run:
    - name: echo ceph_conf_getconf_getadminkeyring_available
    - unless: true
    - require:
      - file: ceph_conf_getconf_getadminkeyring__file_/etc/ceph
      - file: ceph_conf_getconf_getadminkeyring__file_{{admin_keyring}}

{% else %}
ceph_conf_getconf_getadminkeyring__false:
  cmd.run:
    - name: false
{% endif %}

{% endif %}
