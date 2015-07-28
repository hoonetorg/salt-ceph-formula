{% set cluster = salt['pillar.get']('cephname') -%}
{% set cluster_data = salt['pillar.get']('ceph:clusters:' + cluster ,{}) -%}
{% if cluster != '' %}

ceph_pools_create__rbd_available_{{cluster}}:
  cmd.run:
    - name: rbd --cluster {{cluster}} ls
    - unless: rbd --cluster {{cluster}} ls
    - timeout: 60

{% for pool, pool_data in cluster_data.pools.items()|sort %}
ceph_pools_create__pool_create_{{cluster}}_{{pool}}:
  cmd.run:
    - name: ceph --cluster {{cluster}} osd pool create {{pool}} {{cluster_data.global.pg_num}} {{cluster_data.global.pgp_num}}
    - unless: sleep 5;ceph --cluster {{cluster}} osd lspools|grep -w {{pool}}
    - require:
      - cmd: ceph_pools_create__rbd_available_{{cluster}}

{% endfor %}
{% endif %}
