{% set basepathsls = sls.split('.')[0] -%}
{% set environment = salt['pillar.get']('environment')-%}

ceph_conf_getconf_getbootstrapmdskeyring__file_/var/lib/ceph/bootstrap-mds:
  file.directory:
    - name: /var/lib/ceph/bootstrap-mds
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

{% set cluster = salt['pillar.get']('cephname') -%}
{% set cluster_data = salt['pillar.get']('ceph:clusters:' + cluster ,{}) -%}
{% if cluster != '' %}

{% set bootstrap_mds_keyring = '/var/lib/ceph/bootstrap-mds/' + cluster + '.keyring' -%}

{% if salt['cp.list_master'](environment).count('files/keys/' + basepathsls + '/' + cluster + '/backup/' + cluster + '.bootstrap-mds.keyring') != 0 %}

ceph_conf_getconf_getbootstrapmdskeyring__file_{{bootstrap_mds_keyring}}:
  file.managed:
    - name: {{bootstrap_mds_keyring}}
    - template: jinja
    - source: salt://files/keys/{{ basepathsls }}/{{cluster}}/backup/{{cluster}}.bootstrap-mds.keyring
    - user: root
    - group: root
    - mode: '0600'
    - require:
      - file: ceph_conf_getconf_getbootstrapmdskeyring__file_/var/lib/ceph/bootstrap-mds

{% else %}
ceph_conf_getconf_getbootstrapmdskeyring__false:
  cmd.run:
    - name: false
{% endif %}

{% endif %}
