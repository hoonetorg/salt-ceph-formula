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

{% set filepath = filebasepath + "/ceph/files/keys/" + cephname %}
ceph_conf_copyconf__file_{{filepath}}:
  file.directory:
    - name: {{filepath}}
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

ceph_conf_copyconf__cmd_copy_{{cephname}}.client.admin.keyring:
  cmd.run:
    - name: cp {{cachedir}}/minions/{{cephmanagementserver}}/files/etc/ceph/{{cephname}}.client.admin.keyring {{filepath}}/{{cephname}}.client.admin.keyring
    - unless: diff {{cachedir}}/minions/{{cephmanagementserver}}/files/etc/ceph/{{cephname}}.client.admin.keyring {{filepath}}/{{cephname}}.client.admin.keyring
    - reload_modules: True
    - require:
      - file: ceph_conf_copyconf__file_{{filepath}}

ceph_conf_copyconf__file_{{cephname}}.client.admin.keyring:
  file.managed:
    - name: {{filepath}}/{{cephname}}.client.admin.keyring
    - user: root
    - group: root
    - mode: '0400'
    - reload_modules: True
    - require:
      - cmd: ceph_conf_copyconf__cmd_copy_{{cephname}}.client.admin.keyring
    - require_in:
      - module: ceph_conf_copyconf__update_fileserver

ceph_conf_copyconf__cmd_copy_{{cephname}}.mon.keyring:
  cmd.run:
    - name: cp {{cachedir}}/minions/{{cephmanagementserver}}/files/var/lib/ceph/tmp/{{cephname}}.mon.keyring {{filepath}}/{{cephname}}.mon.keyring
    - unless: diff {{cachedir}}/minions/{{cephmanagementserver}}/files/var/lib/ceph/tmp/{{cephname}}.mon.keyring {{filepath}}/{{cephname}}.mon.keyring
    - reload_modules: True
    - require:
      - file: ceph_conf_copyconf__file_{{cephname}}.client.admin.keyring
      - file: ceph_conf_copyconf__file_{{filepath}}

ceph_conf_copyconf__file_{{cephname}}.mon.keyring:
  file.managed:
    - name: {{filepath}}/{{cephname}}.mon.keyring
    - user: root
    - group: root
    - mode: '0400'
    - reload_modules: True
    - require:
      - cmd: ceph_conf_copyconf__cmd_copy_{{cephname}}.mon.keyring
    - require_in:
      - module: ceph_conf_copyconf__update_fileserver

ceph_conf_copyconf__cmd_copy_{{cephname}}monmap:
  cmd.run:
    - name: cp {{cachedir}}/minions/{{cephmanagementserver}}/files/var/lib/ceph/tmp/{{cephname}}monmap {{filepath}}/{{cephname}}monmap
    - unless: diff {{cachedir}}/minions/{{cephmanagementserver}}/files/var/lib/ceph/tmp/{{cephname}}monmap {{filepath}}/{{cephname}}monmap
    - reload_modules: True
    - require:
      - file: ceph_conf_copyconf__file_{{cephname}}.mon.keyring
      - file: ceph_conf_copyconf__file_{{filepath}}

ceph_conf_copyconf__file_{{cephname}}monmap:
  file.managed:
    - name: {{filepath}}/{{cephname}}monmap
    - user: root
    - group: root
    - mode: '0400'
    - reload_modules: True
    - require:
      - cmd: ceph_conf_copyconf__cmd_copy_{{cephname}}monmap
    - require_in:
      - module: ceph_conf_copyconf__update_fileserver


ceph_conf_copyconf__update_fileserver:
  module.run:
    - name: saltutil.runner
    - _fun: fileserver.update
    - reload_modules: True
    - require_in:
      - cmd: ceph_conf_copyconf__fileserver_update
    

ceph_conf_copyconf__fileserver_update:
  cmd.run:
    - name: salt-run -l debug fileserver.update 
    - reload_modules: True
  

ceph_conf_copyconf__cmd_refresh_pillar:
  cmd.run:
    - name: salt-call -l debug saltutil.refresh_pillar
    - require: 
      - cmd: ceph_conf_copyconf__fileserver_update

ceph_conf_copyconf__available:
  cmd.run:
    - name: salt-call -l debug saltutil.sync_all
    - require: 
      - cmd: ceph_conf_copyconf__cmd_refresh_pillar

{% else %}

ceph_conf_copyconf__available:
  cmd.run:
    - name: false
    - reload_modules: True

{% endif %}
