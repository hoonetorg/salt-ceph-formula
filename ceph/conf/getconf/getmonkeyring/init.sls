{% set basepathsls = sls.split('.')[0] -%}
{% set environment = salt['pillar.get']('environment')-%}

ceph_conf_getconf_getmonkeyring__cmd_refresh_pillar:
  cmd.run:
    - name: salt-call -l debug saltutil.refresh_pillar

ceph_conf_getconf_getmonkeyring__sync_all:
  cmd.run:
    - name: salt-call -l debug saltutil.sync_all
    - require:
      - cmd: ceph_conf_getconf_getmonkeyring__cmd_refresh_pillar

ceph_conf_getconf_getmonkeyring__file_/var/lib/ceph/tmp:
  file.directory:
    - name: /var/lib/ceph/tmp
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
    - require:
      - cmd: ceph_conf_getconf_getmonkeyring__sync_all

{% set cluster = salt['pillar.get']('cephname') -%}
{% set cluster_data = salt['pillar.get']('ceph:clusters:' + cluster ,{}) -%}
{% if cluster != '' %}

{% set host = cluster_data.cephhostname -%}

{% set mon_keyring = '/var/lib/ceph/tmp/' + cluster + '.mon.keyring' -%}

{% if salt['cp.list_master'](environment).count( basepathsls + '/files/keys/' + cluster + '/' + cluster + '.mon.keyring') != 0 %}

ceph_conf_getconf_getmonkeyring__file_{{mon_keyring}}:
  file.managed:
    - name: {{mon_keyring}}
    - template: jinja
    - source: salt://{{ basepathsls }}/files/keys/{{cluster}}/{{cluster}}.mon.keyring
    - user: root
    - group: root
    - mode: '0600'
    - onlyif: test ! -d /var/lib/ceph/mon/{{ cluster }}-{{ host }} 
    - require:
      - file: ceph_conf_getconf_getmonkeyring__file_/var/lib/ceph/tmp

{% else %}
ceph_conf_getconf_getmonkeyring__false:
  cmd.run:
    - name: false
{% endif %}

{% endif %}
