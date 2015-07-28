{% set basepathsls = sls.split('.')[0] -%}
{% set environment = salt['pillar.get']('environment')-%}

ceph_conf_genconf_genmonkeyring__file_/var/lib/ceph/tmp:
  file.directory:
    - name: /var/lib/ceph/tmp
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

{% set cluster = salt['pillar.get']('cephname') -%}
{% set cluster_data = salt['pillar.get']('ceph:clusters:' + cluster ,{}) -%}
{% if cluster != '' %}

{% set admin_keyring = '/etc/ceph/' + cluster + '.client.admin.keyring' -%}
{% set host = cluster_data.cephhostname -%}
{% set mon_keyring = '/var/lib/ceph/tmp/' + cluster + '.mon.keyring' -%}

{% if salt['cp.list_master'](environment).count('files/keys/' + basepathsls + '/' + cluster + '/' + cluster + '.mon.keyring') == 0 %}

ceph_conf_genconf_genmonkeyring__gen_mon_keyring_{{cluster}}:
  cmd.run:
    - name: |
        ceph-authtool --cluster {{ cluster }} \
                      --create-keyring {{ mon_keyring }} \
                      --gen-key -n mon. \
                      --cap mon 'allow *'
    - unless: test -d /var/lib/ceph/mon/{{ cluster }}-{{ host }} || test -f {{ mon_keyring }}
    - require:
      - file: ceph_conf_genconf_genmonkeyring__file_/var/lib/ceph/tmp

ceph_conf_genconf_genmonkeyring__import_keyring_{{cluster}}:
  cmd.run:
    - name: |
        ceph-authtool --cluster {{ cluster }} {{ mon_keyring }} \
                      --import-keyring {{ admin_keyring }}
    - onlyif: test ! -d /var/lib/ceph/mon/{{ cluster }}-{{ host }} 
    - unless: ceph-authtool {{ mon_keyring }} --list | grep '^\[client.admin\]'
    - require:
      - file: ceph_conf_genconf_genmonkeyring__file_/var/lib/ceph/tmp
      - cmd: ceph_conf_genconf_genmonkeyring__gen_mon_keyring_{{cluster}}

ceph_conf_genconf_genmonkeyring__cp_push_{{ mon_keyring }}:
  module.run:
    - name: cp.push
    - path: {{ mon_keyring }}
    - require:
      - cmd: ceph_conf_genconf_genmonkeyring__import_keyring_{{cluster}}
    - require_in:
      - cmd: ceph_conf_genconf_genmonkeyring__available

{% endif%}

{% endif%}

ceph_conf_genconf_genmonkeyring__available:
  cmd.run:
    - name: echo ceph_conf_genconf_genmonkeyring__available
    - unless: true

