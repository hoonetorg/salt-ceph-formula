{% set cluster = salt['pillar.get']('cephname') -%}
{% set cluster_data = salt['pillar.get']('ceph:clusters:' + cluster ,{}) -%}
{% if cluster != '' %}

{% if cluster_data.osd.create_empty_osds is defined and cluster_data.osd.create_empty_osds != "" %}
{% for osdnum in range(cluster_data.osd.create_empty_osds) %}
ceph_osd_emptyosds__create_empty_osds_{{cluster}}_{{osdnum}}:
  cmd.run:
    - unless: ceph --cluster {{cluster}} osd ls|egrep "^{{ cluster_data.osd.create_empty_osds -1 }}$"
    - name: ceph --cluster {{ cluster }} osd create
    - require_in:
      - cmd: ceph_osd_emptyosds__create_empty_osds_done_{{cluster}}
{% endfor %}
{% endif %}

ceph_osd_emptyosds__create_empty_osds_done_{{cluster}}:
  cmd.run:
    - name: echo "creating empty osds done"
    - unless: true

{% endif %}
