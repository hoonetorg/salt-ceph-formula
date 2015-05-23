{% set basepathsls = sls.split('.')[0] -%}
{% set environment = salt['pillar.get']('environment')-%}

ceph_conf_getconf_getmonkeyring__file_/var/lib/ceph/tmp:
  file.directory:
    - name: /var/lib/ceph/tmp
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

{% set cluster = salt['pillar.get']('cephname') -%}
{% set cluster_data = salt['pillar.get']('ceph:clusters:' + cluster ,{}) -%}
{% if cluster != '' %}

{% set host = cluster_data.cephhostname -%}

{% set mon_keyring = '/var/lib/ceph/tmp/' + cluster + '.mon.keyring' -%}

{% if salt['cp.list_master'](environment).count('files/keys/' + basepathsls + '/' + cluster + '/' + cluster + '.mon.keyring') != 0 %}

ceph_conf_getconf_getmonkeyring__file_{{mon_keyring}}:
  file.managed:
    - name: {{mon_keyring}}
    - template: jinja
    - source: salt://files/keys/{{ basepathsls }}/{{cluster}}/{{cluster}}.mon.keyring
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
