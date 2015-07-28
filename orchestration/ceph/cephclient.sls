{% set cephname = salt['pillar.get']('cephname') -%}
{% set cephenvironment = salt['pillar.get']('cephenvironment') -%}

{% if cephname is defined and cephname != '' and cephenvironment is defined and cephenvironment != '' %}

{% set cephclients = salt['pillar.get'](cephenvironment + ":ceph:members:" + cephname + ":clients" , False)|sort -%}
# cephclients: {{cephclients}}

{% if cephclients is defined and cephclients %}

##orchestration_cephclient__clients_highstate:
#  salt.state:
#    - tgt: {{cephclients}}
#    - tgt_type: list
#    - expect_minions: True
#    - highstate: True

orchestration_cephclient__clients_prepclient:
  salt.state:
    - tgt: {{cephclients}}
    - tgt_type: list
    - expect_minions: True
    - sls: ceph.prep.client
    - pillar:
        cephname: {{cephname}}
#    - require:
#      - salt: orchestration_cephclient__clients_highstate

orchestration_cephclient__client_getconf:
  salt.state:
    - tgt: {{cephclients}}
    - tgt_type: list
    - expect_minions: True
    - sls: ceph.conf.getconf.getclientconf
    - pillar:
        cephname: {{cephname}}
    - require:
      - salt: orchestration_cephclient__clients_prepclient

{% endif %}

{% endif %}
