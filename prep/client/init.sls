{% set basepathsls = sls.split('.')[0] -%}

include: 
  - {{basepathsls}}.prep.client.package
  - {{basepathsls}}.prep.cephconf

ceph_prep_client__connect_pkg_conf:
  cmd.run:
    - name: echo ceph_prep_client__connect_pkg_conf
    - unless: true
    - require:
      - pkg: ceph_prep_client_package__pkg_ceph-common-package
    - require_in:
      - file: ceph_prep_cephconf__file_/etc/ceph


ceph_prep_client__available:
  cmd.run:
    - name: echo ceph_prep_client__available
    - unless: true
    - require:
      - cmd: ceph_prep_client__connect_pkg_conf
      - sls: {{basepathsls}}.prep.cephconf
