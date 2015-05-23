{% set basepathsls = sls.split('.')[0] -%}
{% set environment = salt['pillar.get']('environment')-%}

ceph_conf_getconf_getbootstraprgwkeyring__file_/var/lib/ceph/bootstrap-rgw:
  file.directory:
    - name: /var/lib/ceph/bootstrap-rgw
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

{% set cluster = salt['pillar.get']('cephname') -%}
{% set cluster_data = salt['pillar.get']('ceph:clusters:' + cluster ,{}) -%}
{% if cluster != '' %}

{% set bootstrap_rgw_keyring = '/var/lib/ceph/bootstrap-rgw/' + cluster + '.keyring' -%}

{% if salt['cp.list_master'](environment).count('files/keys/' + basepathsls + '/' + cluster + '/backup/' + cluster + '.bootstrap-rgw.keyring') != 0 %}

ceph_conf_getconf_getbootstraprgwkeyring__file_{{bootstrap_rgw_keyring}}:
  file.managed:
    - name: {{bootstrap_rgw_keyring}}
    - template: jinja
    - source: salt://files/keys/{{ basepathsls }}/{{cluster}}/backup/{{cluster}}.bootstrap-rgw.keyring
    - user: root
    - group: root
    - mode: '0600'
    - require:
      - file: ceph_conf_getconf_getbootstraprgwkeyring__file_/var/lib/ceph/bootstrap-rgw

{% else %}
ceph_conf_getconf_getbootstraprgwkeyring__false:
  cmd.run:
    - name: false
{% endif %}

{% endif %}
