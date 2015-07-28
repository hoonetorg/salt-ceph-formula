{% set basepathsls = sls.split('.')[0] -%}
include: 
  - {{basepathsls}}.prep.server.package
  - {{basepathsls}}.prep.cephconf

ceph_prep_server__connect_pkg_conf:
  cmd.run:
    - name: echo ceph_prep_server__connect_pkg_conf
    - unless: true
    - require:
      - pkg: ceph_prep_server_package__pkg_ceph-package
    - require_in:
      - file: ceph_prep_cephconf__file_/etc/ceph

ceph_server__file_/var/lib/ceph:
  file.directory:
    - name: /var/lib/ceph
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
    - require:
      - cmd: ceph_prep_cephconf__available

ceph_server__file_/var/run/ceph:
  file.directory:
    - name: /var/run/ceph
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
    - require:
      - file: ceph_server__file_/var/lib/ceph

ceph_server__file_/var/log/ceph:
  file.directory:
    - name: /var/log/ceph
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
    - require:
      - file: ceph_server__file_/var/run/ceph

{% set cluster = salt['pillar.get']('cephname') -%}
{% set cluster_data = salt['pillar.get']('ceph:clusters:' + cluster ,{}) -%}

{% if cluster != '' and cluster != "ceph" %}

ceph_server__file_/etc/init.d/{{cluster}}:
  file.managed:
    - name: /etc/init.d/{{cluster}}
    - user: root
    - group: root
    - mode: 755
    - require:
      - file: ceph_server__file_/var/log/ceph
    - contents: |
        #!/bin/sh
        # Start/stop {{cluster}} daemons
        # chkconfig: 2345 60 80
        
        ### BEGIN INIT INFO
        # Provides:          {{cluster}}
        # Default-Start:     2 3 4 5
        # Default-Stop:      0 1 6
        # Required-Start:    $remote_fs $named $network $time
        # Required-Stop:     $remote_fs $named $network $time
        # Short-Description: Start Ceph distributed file system daemons at boot time
        # Description:       Enable Ceph distributed file system services.
        ### END INIT INFO

        service ceph --cluster {{cluster}} $@

ceph_server__service_{{cluster}}_added:
  cmd.run:
    - name: chkconfig --add {{cluster}}
    - unless: chkconfig {{cluster}}
    - require:
      - file: ceph_server__file_/etc/init.d/{{cluster}}
    - require_in:
      - cmd: ceph_server__available

{% endif %}

ceph_server__available:
  cmd.run:
    - name: echo ceph_server__available
    - unless: true
