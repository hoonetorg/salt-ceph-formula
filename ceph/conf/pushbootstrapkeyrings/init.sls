{% set basepathsls = sls.split('.')[0] -%}

{% set cluster = salt['pillar.get']('cephname') -%}
{% set cluster_data = salt['pillar.get']('ceph:clusters:' + cluster ,{}) -%}
{% if cluster != '' %}

{% set bootstrap_osd_keyring = '/var/lib/ceph/bootstrap-osd/' + cluster + '.keyring' -%}
{% set bootstrap_mds_keyring = '/var/lib/ceph/bootstrap-mds/' + cluster + '.keyring' -%}
{% set bootstrap_rgw_keyring = '/var/lib/ceph/bootstrap-rgw/' + cluster + '.keyring' -%}

{% if salt['cp.list_master'](env).count( basepathsls + '/files/keys/' + cluster + '/backup/' + cluster + '.bootstrap-osd.keyring') == 0 %}

ceph_conf_pushbootstrapkeyrings__bootstrap_osd_keyring_available:
  cmd.run:
    - name: while ! test -f {{ bootstrap_osd_keyring }}; do sleep 1; done
    - unless: test -f {{ bootstrap_osd_keyring }}
    - timeout: 30

ceph_conf_pushbootstrapkeyrings__cp_push_{{bootstrap_osd_keyring}}:
  module.run:
    - name: cp.push
    - path: {{ bootstrap_osd_keyring }}
    - require:
      - cmd: ceph_conf_pushbootstrapkeyrings__bootstrap_osd_keyring_available
    - require_in:
      - cmd: ceph_conf_pushbootstrapkeyrings__available

{% endif%}

{% if salt['cp.list_master'](env).count( basepathsls + '/files/keys/' + cluster + '/backup/' + cluster + '.bootstrap-mds.keyring') == 0 %}

ceph_conf_pushbootstrapkeyrings__bootstrap_mds_keyring_available:
  cmd.run:
    - name: while ! test -f {{ bootstrap_mds_keyring }}; do sleep 1; done
    - unless: test -f {{ bootstrap_mds_keyring }}
    - timeout: 30

ceph_conf_pushbootstrapkeyrings__cp_push_{{bootstrap_mds_keyring}}:
  module.run:
    - name: cp.push
    - path: {{ bootstrap_mds_keyring }}
    - require:
      - cmd: ceph_conf_pushbootstrapkeyrings__bootstrap_mds_keyring_available
    - require_in:
      - cmd: ceph_conf_pushbootstrapkeyrings__available

{% endif%}

{% if salt['cp.list_master'](env).count( basepathsls + '/files/keys/' + cluster + '/backup/' + cluster + '.bootstrap-rgw.keyring') == 0 %}

ceph_conf_pushbootstrapkeyrings__bootstrap_rgw_keyring_available:
  cmd.run:
    - name: while ! test -f {{ bootstrap_rgw_keyring }}; do sleep 1; done
    - unless: test -f {{ bootstrap_rgw_keyring }}
    - timeout: 30

ceph_conf_pushbootstrapkeyrings__cp_push_{{bootstrap_rgw_keyring}}:
  module.run:
    - name: cp.push
    - path: {{ bootstrap_rgw_keyring }}
    - require:
      - cmd: ceph_conf_pushbootstrapkeyrings__bootstrap_rgw_keyring_available
    - require_in:
      - cmd: ceph_conf_pushbootstrapkeyrings__available

{% endif%}

{% endif%}

ceph_conf_pushbootstrapkeyrings__available:
  cmd.run:
    - name: echo ceph_conf_pushbootstrapkeyrings__available
    - unless: true

