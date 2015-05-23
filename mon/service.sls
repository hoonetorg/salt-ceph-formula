ceph_mon_service__file_/var/lib/ceph/bootstrap-osd:
  file.directory:
    - name: /var/lib/ceph/bootstrap-osd
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

ceph_mon_service__file_/var/lib/ceph/bootstrap-mds:
  file.directory:
    - name: /var/lib/ceph/bootstrap-mds
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

ceph_mon_service__file_/var/lib/ceph/bootstrap-rgw:
  file.directory:
    - name: /var/lib/ceph/bootstrap-rgw
    - user: root
    - group: root
    - mode: 755
    - makedirs: True


{% set cluster = salt['pillar.get']('cephname') -%}
{% set cluster_data = salt['pillar.get']('ceph:clusters:' + cluster ,{}) -%}
{% if cluster != '' %}

ceph_mon_service__service_mon_{{cluster}}:
  service:
    - running
    - enable: True
    - name: {{ cluster }}
    - require:
      - file: ceph_mon_service__file_/var/lib/ceph/bootstrap-osd
      - file: ceph_mon_service__file_/var/lib/ceph/bootstrap-mds
      - file: ceph_mon_service__file_/var/lib/ceph/bootstrap-rgw

{% endif -%}
