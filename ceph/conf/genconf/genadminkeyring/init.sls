{% set basepathsls = sls.split('.')[0] -%}
{% set environment = salt['pillar.get']('environment')-%}

ceph_conf_genconf_genadminkeyring__file_/etc/ceph:
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

{% if salt['cp.list_master'](environment).count( basepathsls + '/files/keys/' + cluster + '/' + cluster + '.client.admin.keyring') == 0 %}

ceph_conf_genconf_genadminkeyring__gen_admin_keyring_{{cluster}}:
  cmd.run:
    - name: |
        ceph-authtool --cluster {{ cluster }} \
                      --create-keyring {{ admin_keyring }} \
                      --gen-key -n client.admin \
                      --set-uid=0 \
                      --cap mon 'allow *' \
                      --cap osd 'allow *' \
                      --cap mds 'allow *'
    - unless: test -f {{ admin_keyring }}
    - require:
      - file: ceph_conf_genconf_genadminkeyring__file_/etc/ceph

ceph_conf_genconf_genadminkeyring__cp_push_{{ admin_keyring }}:
  module.run:
    - name: cp.push
    - path: {{ admin_keyring }}
    - require:
      - cmd: ceph_conf_genconf_genadminkeyring__gen_admin_keyring_{{cluster}}
    - require_in:
      - cmd: ceph_conf_genconf_genadminkeyring__available
{% endif%}

{% endif %}

ceph_conf_genconf_genadminkeyring__available:
  cmd.run:
    - name: echo ceph_conf_genconf_genadminkeyring__available
    - unless: true

