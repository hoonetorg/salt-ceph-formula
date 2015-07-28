{% set cephname = salt['pillar.get']('cephname') -%}
{% set cephenvironment = salt['pillar.get']('cephenvironment') -%}

{% if cephname is defined and cephname != '' and cephenvironment is defined and cephenvironment != '' %}

{% set cephlibvirtclients = salt['pillar.get'](cephenvironment + ":ceph:members:" + cephname + ":libvirtclients" , False)|sort -%}
# cephlibvirtclients: {{cephlibvirtclients}}

{% if cephlibvirtclients is defined and cephlibvirtclients %}

#orchestration_libvirtceph__libvirtclients_highstate:
#  salt.state:
#    - tgt: {{cephlibvirtclients}}
#    - tgt_type: list
#    - expect_minions: True
#    - highstate: True

orchestration_libvirtceph__libvirtclients_virt_ceph:
  salt.state:
    - tgt: {{cephlibvirtclients}}
    - tgt_type: list
    - expect_minions: True
    - sls: virt.ceph 
    - pillar:
        cephname: {{cephname}}
#    - require:
#      - salt: orchestration_libvirtceph__libvirtclients_highstate

{% endif %}

{% endif %}
