{% set basepathsls = sls.split('.')[0] -%}

include:
  - {{basepathsls}}.prep.etchosts
 
ceph_prep_cephconf__file_/etc/ceph:
  file.directory:
    - name: /etc/ceph
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
    - require:
      - cmd: ceph_prep_etchosts__available

{% set cluster = salt['pillar.get']('cephname') -%}
{% set cluster_data = salt['pillar.get']('ceph:clusters:' + cluster ,{}) -%}
{% if cluster != '' %}
{% set conf_file = '/etc/ceph/' + cluster + '.conf' -%}

ceph_prep_cephconf__file_{{conf_file}}:
  file.managed:
    - name: {{conf_file}}
    - template: jinja
    - source: salt://{{ basepathsls }}/files/etc/ceph/ceph.conf
    - user: root
    - group: root
    - mode: '0644'
    - context:
      cluster_data: {{ cluster_data }}
    - require:
      - file: ceph_prep_cephconf__file_/etc/ceph
    - require_in:
      - cmd: ceph_prep_cephconf__available

{% endif %}

ceph_prep_cephconf__available:
  cmd.run:
    - name: echo ceph_prep_cephconf__available
    - unless: true

