{% set basepathsls = sls.split('.')[0] -%}
{% set environment = salt['pillar.get']('environment')-%}

ceph_conf_getconf_getbootstraposdkeyring__file_/var/lib/ceph/bootstrap-osd:
  file.directory:
    - name: /var/lib/ceph/bootstrap-osd
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

{% set cluster = salt['pillar.get']('cephname') -%}
{% set cluster_data = salt['pillar.get']('ceph:clusters:' + cluster ,{}) -%}
{% if cluster != '' %}

{% set bootstrap_osd_keyring = '/var/lib/ceph/bootstrap-osd/' + cluster + '.keyring' -%}

{% if salt['cp.list_master'](environment).count('files/keys/' + basepathsls + '/' + cluster + '/backup/' + cluster + '.bootstrap-osd.keyring') != 0 %}

ceph_conf_getconf_getbootstraposdkeyring__file_{{bootstrap_osd_keyring}}:
  file.managed:
    - name: {{bootstrap_osd_keyring}}
    - template: jinja
    - source: salt://files/keys/{{ basepathsls }}/{{cluster}}/backup/{{cluster}}.bootstrap-osd.keyring
    - user: root
    - group: root
    - mode: '0600'
    - require:
      - file: ceph_conf_getconf_getbootstraposdkeyring__file_/var/lib/ceph/bootstrap-osd

{% else %}
ceph_conf_getconf_getbootstraposdkeyring__false:
  cmd.run:
    - name: false
{% endif %}

{% endif %}
