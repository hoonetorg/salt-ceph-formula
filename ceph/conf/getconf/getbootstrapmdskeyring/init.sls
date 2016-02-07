{% set basepathsls = sls.split('.')[0] -%}

ceph_conf_getconf_getbootstrapmdskeyring__cmd_refresh_pillar:
  cmd.run:
    - name: salt-call -l debug saltutil.refresh_pillar

ceph_conf_getconf_getbootstrapmdskeyring__sync_all:
  cmd.run:
    - name: salt-call -l debug saltutil.sync_all
    - require:
      - cmd: ceph_conf_getconf_getbootstrapmdskeyring__cmd_refresh_pillar

ceph_conf_getconf_getbootstrapmdskeyring__file_/var/lib/ceph/bootstrap-mds:
  file.directory:
    - name: /var/lib/ceph/bootstrap-mds
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
    - require:
      - cmd: ceph_conf_getconf_getbootstrapmdskeyring__sync_all

{% set cluster = salt['pillar.get']('cephname') -%}
{% set cluster_data = salt['pillar.get']('ceph:clusters:' + cluster ,{}) -%}
{% if cluster != '' %}

{% set bootstrap_mds_keyring = '/var/lib/ceph/bootstrap-mds/' + cluster + '.keyring' -%}

{% if salt['cp.list_master'](env).count( basepathsls + '/files/keys/' + cluster + '/backup/' + cluster + '.bootstrap-mds.keyring') != 0 %}

ceph_conf_getconf_getbootstrapmdskeyring__file_{{bootstrap_mds_keyring}}:
  file.managed:
    - name: {{bootstrap_mds_keyring}}
    - template: jinja
    - source: salt://{{ basepathsls }}/files/keys/{{cluster}}/backup/{{cluster}}.bootstrap-mds.keyring
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
