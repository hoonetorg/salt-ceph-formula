{% set cluster = salt['pillar.get']('cephname') -%}
{% set cluster_data = salt['pillar.get']('ceph:clusters:' + cluster ,{}) -%}
{% if cluster != '' %}

{% for keyring, keyring_data in cluster_data.keyrings.items()|sort %}
ceph_pools_auth__gen_keyring_{{cluster}}_{{keyring}}:
  cmd.run:
    - name: |
        ceph --cluster {{ cluster }} auth get-or-create client.{{keyring}} {{keyring_data}}
    - unless: sleep5; ceph --cluster {{ cluster }} auth get client.{{keyring}}

{% endfor %}

{% endif %}
