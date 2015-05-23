{% set basepathsls = sls.split('.')[0] -%}
{% set environment = salt['pillar.get']('environment')-%}

ceph_conf_genconf_genmonmap__file_/var/lib/ceph/tmp:
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
{% set fsid = cluster_data.global.fsid -%}
{% set monmap = '/var/lib/ceph/tmp/' + cluster + 'monmap' -%}

{% if salt['cp.list_master'](environment).count('files/keys/' + basepathsls + '/' + cluster + '/' + cluster + 'monmap') == 0 %}

ceph_conf_genconf_genmonmap__gen_monmap_{{cluster}}:
  cmd.run:
    - name: |
        monmaptool --cluster {{ cluster }} \
                   --create \
{%- for mon, mon_data in cluster_data.mons.items()|sort -%}
                   --add {{ mon }} {{ mon_data.public_ip }} \
{%- endfor -%}
                   --fsid {{ fsid }} {{ monmap }}
    - unless: test -d /var/lib/ceph/mon/{{ cluster }}-{{ host }} || test -f {{ monmap }}
    - require:
      - file: ceph_conf_genconf_genmonmap__file_/var/lib/ceph/tmp

ceph_conf_genconf_genmonmap__cp_push_{{monmap}}:
  module.run:
    - name: cp.push
    - path: {{monmap}}
    - require:
      - cmd: ceph_conf_genconf_genmonmap__gen_monmap_{{cluster}}
    - require_in:
      - cmd: ceph_conf_genconf_genmonmap__available

{% endif%}

{% endif %}

ceph_conf_genconf_genmonmap__available:
  cmd.run:
    - name: echo ceph_conf_genconf_genmonmap__available
    - unless: true

