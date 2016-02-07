{% set cephenvironment = salt['pillar.get']('cephenvironment') -%}
# cephenvironment: "{{cephenvironment}}"
{% set cephname = salt['pillar.get']('cephname') -%}
# cephname: "{{cephname}}"

{% set cachedir = salt['pillar.get']("cachedir" ) -%}
{% set cephmanagementserver = salt['pillar.get'](cephenvironment + ":ceph:members:" + cephname + ":managementserver" ) -%}
# cephmanagementserver: "{{cephmanagementserver}}"
{% set filebasepath = salt['pillar.get']("filebasepath") + '/' + cephenvironment  -%}
# filebasepath: "{{filebasepath}}"

{% if cephmanagementserver is defined and cephmanagementserver != '' and filebasepath is defined and filebasepath != '' %}

{% set filepath = filebasepath + "/ceph/files/keys/" + cephname + "/backup" %}
ceph_conf_copybootstrapkeyrings__file_{{filepath}}:
  file.directory:
    - name: {{filepath}}
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

ceph_conf_copybootstrapkeyrings__cmd_copy_{{cephname}}.bootstrap-osd.keyring:
  cmd.run:
    - name: cp {{cachedir}}/minions/{{cephmanagementserver}}/files/var/lib/ceph/bootstrap-osd/{{cephname}}.keyring {{filepath}}/{{cephname}}.bootstrap-osd.keyring
    - unless: diff {{cachedir}}/minions/{{cephmanagementserver}}/files/var/lib/ceph/bootstrap-osd/{{cephname}}.keyring {{filepath}}/{{cephname}}.bootstrap-osd.keyring
    - reload_modules: True
    - require:
      - file: ceph_conf_copybootstrapkeyrings__file_{{filepath}}

ceph_conf_copybootstrapkeyrings__file_{{cephname}}.bootstrap-osd.keyring:
  file.managed:
    - name: {{filepath}}/{{cephname}}.bootstrap-osd.keyring
    - user: root
    - group: root
    - mode: '0400'
    - reload_modules: True
    - require:
      - cmd: ceph_conf_copybootstrapkeyrings__cmd_copy_{{cephname}}.bootstrap-osd.keyring
    - require_in:
      - module: ceph_conf_copybootstrapkeyrings__update_fileserver

ceph_conf_copybootstrapkeyrings__cmd_copy_{{cephname}}.bootstrap-mds.keyring:
  cmd.run:
    - name: cp {{cachedir}}/minions/{{cephmanagementserver}}/files/var/lib/ceph/bootstrap-mds/{{cephname}}.keyring {{filepath}}/{{cephname}}.bootstrap-mds.keyring
    - unless: diff {{cachedir}}/minions/{{cephmanagementserver}}/files/var/lib/ceph/bootstrap-mds/{{cephname}}.keyring {{filepath}}/{{cephname}}.bootstrap-mds.keyring
    - reload_modules: True
    - require:
      - file: ceph_conf_copybootstrapkeyrings__file_{{filepath}}

ceph_conf_copybootstrapkeyrings__file_{{cephname}}.bootstrap-mds.keyring:
  file.managed:
    - name: {{filepath}}/{{cephname}}.bootstrap-mds.keyring
    - user: root
    - group: root
    - mode: '0400'
    - reload_modules: True
    - require:
      - cmd: ceph_conf_copybootstrapkeyrings__cmd_copy_{{cephname}}.bootstrap-mds.keyring
    - require_in:
      - module: ceph_conf_copybootstrapkeyrings__update_fileserver

ceph_conf_copybootstrapkeyrings__cmd_copy_{{cephname}}.bootstrap-rgw.keyring:
  cmd.run:
    - name: cp {{cachedir}}/minions/{{cephmanagementserver}}/files/var/lib/ceph/bootstrap-rgw/{{cephname}}.keyring {{filepath}}/{{cephname}}.bootstrap-rgw.keyring
    - unless: diff {{cachedir}}/minions/{{cephmanagementserver}}/files/var/lib/ceph/bootstrap-rgw/{{cephname}}.keyring {{filepath}}/{{cephname}}.bootstrap-rgw.keyring
    - reload_modules: True
    - require:
      - file: ceph_conf_copybootstrapkeyrings__file_{{filepath}}

ceph_conf_copybootstrapkeyrings__file_{{cephname}}.bootstrap-rgw.keyring:
  file.managed:
    - name: {{filepath}}/{{cephname}}.bootstrap-rgw.keyring
    - user: root
    - group: root
    - mode: '0400'
    - reload_modules: True
    - require:
      - cmd: ceph_conf_copybootstrapkeyrings__cmd_copy_{{cephname}}.bootstrap-rgw.keyring
    - require_in:
      - module: ceph_conf_copybootstrapkeyrings__update_fileserver

ceph_conf_copybootstrapkeyrings__update_fileserver:
  module.run:
    - name: saltutil.runner
    - _fun: fileserver.update
    - reload_modules: True
    - require_in:
      - cmd: ceph_conf_copybootstrapkeyrings__fileserver_update

ceph_conf_copybootstrapkeyrings__fileserver_update:
  cmd.run:
    - name: salt-run -l debug fileserver.update 
    - reload_modules: True
  

ceph_conf_copybootstrapkeyrings__cmd_refresh_pillar:
  cmd.run:
    - name: salt-call -l debug saltutil.refresh_pillar
    - require: 
      - cmd: ceph_conf_copybootstrapkeyrings__fileserver_update

ceph_conf_copybootstrapkeyrings__available:
  cmd.run:
    - name: salt-call -l debug saltutil.sync_all
    - require: 
      - cmd: ceph_conf_copybootstrapkeyrings__cmd_refresh_pillar

{% else %}

ceph_conf_copybootstrapkeyrings__available:
  cmd.run:
    - name: false
    - reload_modules: True

{% endif %}
