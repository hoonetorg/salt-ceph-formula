{% set cluster = salt['pillar.get']('cephname') -%}
{% set cluster_data = salt['pillar.get']('ceph:clusters:' + cluster ,{}) -%}
{% if cluster != '' %}

ceph_osd_service__service_osd_{{cluster}}:
  service:
    - running
    - enable: True
    - name: {{ cluster }}

{% endif -%}
