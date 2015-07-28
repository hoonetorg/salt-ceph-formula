{% set cluster = salt['pillar.get']('cephname') -%}
{% set cluster_data = salt['pillar.get']('ceph:clusters:' + cluster ,{}) -%}
{% if cluster != '' %}

{% for mon, mon_data in cluster_data.mons.items()|sort -%}
ceph_prep_etchosts__monhost_{{mon}}:
  host.present:
    - ip: {{ mon_data.public_ip }}
    - names:
      - {{mon}}
    - require_in:
      - cmd: ceph_prep_etchosts__available
{% endfor -%}
{% for osd, osd_data in cluster_data.osds.items()|sort -%}
ceph_prep_etchosts__osdhost_{{osd}}:
  host.present:
    - ip: {{ osd_data.public_ip }}
    - names:
      - {{osd}}
    - require_in:
      - cmd: ceph_prep_etchosts__available
{% endfor -%}
{% for mds, mds_data in cluster_data.mdss.items()|sort -%}
ceph_prep_etchosts__mdshost_{{mds}}:
  host.present:
    - ip: {{ mds_data.public_ip }}
    - names:
      - {{mds}}
    - require_in:
      - cmd: ceph_prep_etchosts__available
{% endfor -%}

{% endif %}

ceph_prep_etchosts__available:
  cmd.run:
    - name: echo ceph_prep_etchosts__available
    - unless: true

