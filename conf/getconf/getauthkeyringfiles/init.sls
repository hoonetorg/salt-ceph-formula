ceph_conf_getconf_getauthkeyringfiles__file_/etc/ceph:
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

{% for keyring, keyring_data in cluster_data.keyrings.items()|sort %}

ceph_conf_getconf_getauthkeyringfiles__get_keyring_{{cluster}}_{{keyring}}:
  cmd.run:
    - name: |
        test -f {{admin_keyring}} && ceph --cluster {{ cluster }} auth get client.{{keyring}} -o /etc/ceph/{{cluster}}.client.{{keyring}}.keyring
    - unless: test -f /etc/ceph/{{cluster}}.client.{{keyring}}.keyring
    - require:
      - file: ceph_conf_getconf_getauthkeyringfiles__file_/etc/ceph

{% endfor %}

{% endif %}
