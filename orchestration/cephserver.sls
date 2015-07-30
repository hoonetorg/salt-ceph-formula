{% set cephname = salt['pillar.get']('cephname') -%}
{% set cephenvironment = salt['pillar.get']('cephenvironment') -%}

{% if cephname is defined and cephname != '' and cephenvironment is defined and cephenvironment != '' %}


{% set cephmons = salt['pillar.get'](cephenvironment + ":ceph:members:" + cephname + ":mons" , False)|sort -%}
{% set cephosds = salt['pillar.get'](cephenvironment + ":ceph:members:" + cephname + ":osds" , False)|sort -%}
{% set cephmdss = salt['pillar.get'](cephenvironment + ":ceph:members:" + cephname + ":mdss" , False)|sort -%}
{% set cephservers = cephmons + cephosds + cephmdss -%}

{% set cephmanagementserver = salt['pillar.get'](cephenvironment + ":ceph:members:" + cephname + ":managementserver" , False) -%}

# cephmanagementserver: {{cephmanagementserver}}

{% if cephservers is defined and cephservers %}

#orchestration_cephserver__servers_highstate:
#  salt.state:
#    - tgt: {{cephservers}}
#    - tgt_type: list
#    - expect_minions: True
#    - highstate: True
#    - require_in:
#      - salt: orchestration_cephserver__mons_finished
#      - salt: orchestration_cephserver__osds_finished
#      - salt: orchestration_cephserver__mdss_finished

orchestration_cephserver__servers_prepserver:
  salt.state:
    - tgt: {{cephservers}}
    - tgt_type: list
    - expect_minions: True
    - sls: ceph.prep.server
    - pillar:
        cephname: {{cephname}}
#    - require:
#      - salt: orchestration_cephserver__servers_highstate
    - require_in:
      - salt: orchestration_cephserver__mons_finished
      - salt: orchestration_cephserver__osds_finished
      - salt: orchestration_cephserver__mdss_finished

{% endif %}

{% if cephmons is defined and cephmons %}

{% if cephmanagementserver is defined and cephmanagementserver != '' -%}

orchestration_cephserver__mon_genconf:
  salt.state:
    - tgt: {{cephmanagementserver}}
    - expect_minions: True
    - sls: ceph.conf.genconf
    - pillar:
        cephname: {{cephname}}
    - require:
      - salt: orchestration_cephserver__servers_prepserver

orchestration_cephserver__mon_copyconf:
  salt.state:
    - tgt: '{{grains['fqdn']}}'
    - expect_minions: True
    - sls: ceph.conf.copyconf
    - pillar:
        cephname: {{cephname}}
        cephenvironment: {{cephenvironment}}
    - require:
      - salt: orchestration_cephserver__mon_genconf
    - require_in:
      - salt: orchestration_cephserver__mons_finished

{% endif %}

orchestration_cephserver__mons_refresh_pillar:
  salt.function:
    - tgt: {{cephmons}}
    - tgt_type: list
    - expect_minions: True
    - name: cmd.run
    - arg:
      - "salt-call -l debug saltutil.refresh_pillar"
    - require:
      - salt: orchestration_cephserver__mon_copyconf

orchestration_cephserver__mons_sync_all:
  salt.function:
    - tgt: {{cephmons}}
    - tgt_type: list
    - expect_minions: True
    - name: cmd.run
    - arg:
      - "salt-call -l debug saltutil.sync_all"
    - require:
      - salt: orchestration_cephserver__mons_refresh_pillar

orchestration_cephserver__mon_getconf:
  salt.state:
    - tgt: {{cephmons}}
    - tgt_type: list
    - expect_minions: True
    - sls: ceph.conf.getconf.getmonconf
    - pillar:
        cephname: {{cephname}}
    - require:
      - salt: orchestration_cephserver__servers_prepserver
      - salt: orchestration_cephserver__mon_copyconf
      - salt: orchestration_cephserver__mons_sync_all
    - require_in:
      - salt: orchestration_cephserver__mons_finished

orchestration_cephserver__mon_monpopulate:
  salt.state:
    - tgt: {{cephmons}}
    - tgt_type: list
    - expect_minions: True
    - sls: ceph.mon.populate
    - pillar:
        cephname: {{cephname}}
    - require:
      - salt: orchestration_cephserver__servers_prepserver
      - salt: orchestration_cephserver__mon_getconf
    - require_in:
      - salt: orchestration_cephserver__mons_finished

orchestration_cephserver__mon_service:
  salt.state:
    - tgt: {{cephmons}}
    - tgt_type: list
    - expect_minions: True
    - sls: ceph.mon.service
    - pillar:
        cephname: {{cephname}}
    - require:
      - salt: orchestration_cephserver__servers_prepserver
      - salt: orchestration_cephserver__mon_monpopulate
    - require_in:
      - salt: orchestration_cephserver__mons_finished

{% if cephmanagementserver is defined and cephmanagementserver != '' -%}

orchestration_cephserver__mon_pushbootstrapkeyrings:
  salt.state:
    - tgt: {{cephmanagementserver}}
    - expect_minions: True
    - sls: ceph.conf.pushbootstrapkeyrings
    - pillar:
        cephname: {{cephname}}
    - require:
      - salt: orchestration_cephserver__servers_prepserver
      - salt: orchestration_cephserver__mon_service

orchestration_cephserver__mon_copybootstrapkeyrings:
  salt.state:
    - tgt: '{{grains['fqdn']}}'
    - expect_minions: True
    - sls: ceph.conf.copybootstrapkeyrings
    - pillar:
        cephname: "{{cephname}}"
        cephenvironment: {{cephenvironment}}
    - require:
      - salt: orchestration_cephserver__servers_prepserver
      - salt: orchestration_cephserver__mon_pushbootstrapkeyrings
    - require_in:
      - salt: orchestration_cephserver__mons_finished

{% endif %}

orchestration_cephserver__mons_refresh_pillar_bootstrap:
  salt.function:
    - tgt: {{cephmons}}
    - tgt_type: list
    - expect_minions: True
    - name: cmd.run
    - arg:
      - "salt-call -l debug saltutil.refresh_pillar"
    - require:
      - salt: orchestration_cephserver__mon_copybootstrapkeyrings

orchestration_cephserver__mons_sync_all_bootstrap:
  salt.function:
    - tgt: {{cephmons}}
    - tgt_type: list
    - expect_minions: True
    - name: cmd.run
    - arg:
      - "salt-call -l debug saltutil.sync_all"
    - require:
      - salt: orchestration_cephserver__mons_refresh_pillar_bootstrap

orchestration_cephserver__mon_getbootstrapkeyrings:
  salt.state:
    - tgt: {{cephmons}}
    - tgt_type: list
    - expect_minions: True
    - sls: ceph.conf.getconf.getbootstrapkeyrings
    - pillar:
        cephname: {{cephname}}
    - require:
      - salt: orchestration_cephserver__servers_prepserver
      - salt: orchestration_cephserver__mon_copybootstrapkeyrings
      - salt: orchestration_cephserver__mons_sync_all_bootstrap
    - require_in:
      - salt: orchestration_cephserver__mons_finished

{% endif %}

orchestration_cephserver__mons_finished:
  salt.function:
    - tgt: '{{grains['fqdn']}}'
    - expect_minions: True
    - name: cmd.run
    - arg: 
      - "echo \"`date`: cluster: {{cephname}}: cephmons deployed\" >> /var/log/cephorchestrate.log"

{% if cephosds is defined and cephosds %}

orchestration_cephserver__osds_refresh_pillar:
  salt.function:
    - tgt: {{cephosds}}
    - tgt_type: list
    - expect_minions: True
    - name: cmd.run
    - arg:
      - "salt-call -l debug saltutil.refresh_pillar"
    - require:
      - salt: orchestration_cephserver__mons_finished

orchestration_cephserver__osds_sync_all:
  salt.function:
    - tgt: {{cephosds}}
    - tgt_type: list
    - expect_minions: True
    - name: cmd.run
    - arg:
      - "salt-call -l debug saltutil.sync_all"
    - require:
      - salt: orchestration_cephserver__osds_refresh_pillar


orchestration_cephserver__osd_getconf:
  salt.state:
    - tgt: {{cephosds}}
    - tgt_type: list
    - expect_minions: True
    - sls: ceph.conf.getconf.getosdconf
    - pillar:
        cephname: {{cephname}}
    - require:
      - salt: orchestration_cephserver__servers_prepserver
      - salt: orchestration_cephserver__mons_finished
      - salt: orchestration_cephserver__osds_sync_all
    - require_in:
      - salt: orchestration_cephserver__osds_finished

{% for cephosd in cephosds|sort -%}

#hacky hacky , because of broken init script
orchestration_cephserver__osd_emptyosds_{{cephosd}}:
  salt.state:
    - tgt: {{cephosd}}
    - expect_minions: True
    - sls: ceph.osd.emptyosds
    - pillar:
        cephname: {{cephname}}
    - require:
      - salt: orchestration_cephserver__mons_finished
      - salt: orchestration_cephserver__osd_getconf
    - require_in:
      - salt: orchestration_cephserver__osds_finished
      - salt: orchestration_cephserver__osd_create_{{cephosd}}

orchestration_cephserver__osd_create_{{cephosd}}:
  salt.state:
    - tgt: {{cephosd}}
    - expect_minions: True
    - sls: ceph.osd.create
    - pillar:
        cephname: {{cephname}}
    - require:
      - salt: orchestration_cephserver__mons_finished
      - salt: orchestration_cephserver__osd_getconf
    - require_in:
      - salt: orchestration_cephserver__osds_finished
      - salt: orchestration_cephserver__osd_service

{% endfor %}

orchestration_cephserver__osd_service:
  salt.state:
    - tgt: {{cephosds}}
    - tgt_type: list
    - expect_minions: True
    - sls: ceph.osd.service
    - pillar:
        cephname: {{cephname}}
    - require:
      - salt: orchestration_cephserver__servers_prepserver
      - salt: orchestration_cephserver__mons_finished
    - require_in:
      - salt: orchestration_cephserver__osds_finished

{% endif %}


orchestration_cephserver__osds_finished:
  salt.function:
    - tgt: '{{grains['fqdn']}}'
    - expect_minions: True
    - name: cmd.run
    - arg: 
      - "echo \"`date`: cluster: {{cephname}}: cephosds deployed\" >> /var/log/cephorchestrate.log"
    - require:
      - salt: orchestration_cephserver__mons_finished

{% if cephmdss is defined and cephmdss %}
{% for cephmds in cephmdss|sort -%}

#orchestration_cephserver__mds_setup_{{cephmds}}:
#  salt.state:
#    - tgt: '{{cephmds}}'
#    - expect_minions: True
#    - sls: ceph.mds
#    - pillar:
#        cephname: {{cephname}}
#    - require:
#      - salt: orchestration_cephserver__mons_finished
#      - salt: orchestration_cephserver__osds_finished

{% endfor %}
{% endif %}

{% endif %}

orchestration_cephserver__mdss_finished:
  salt.function:
    - tgt: '{{grains['fqdn']}}'
    - expect_minions: True
    - name: cmd.run
    - arg: 
      - "echo \"`date`: cluster: {{cephname}}: cephmdss deployed\" >> /var/log/cephorchestrate.log"
    - require:
      - salt: orchestration_cephserver__mons_finished
      - salt: orchestration_cephserver__osds_finished

##### POOLS

{% if cephmanagementserver is defined and cephmanagementserver != '' -%}

orchestration_cephserver__pools_create:
  salt.state:
    - tgt: {{cephmanagementserver}}
    - expect_minions: True
    - sls: ceph.pools.create
    - pillar:
        cephname: {{cephname}}
    - require:
      - salt: orchestration_cephserver__servers_prepserver
      - salt: orchestration_cephserver__osds_finished

orchestration_cephserver__pools_auth:
  salt.state:
    - tgt: {{cephmanagementserver}}
    - expect_minions: True
    - sls: ceph.pools.auth
    - pillar:
        cephname: {{cephname}}
    - require:
      - salt: orchestration_cephserver__pools_create

{% endif %}
