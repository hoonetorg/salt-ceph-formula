ceph_mon_populate__file_/var/lib/ceph/mon:
  file.directory:
    - name: /var/lib/ceph/mon
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

{% set cluster = salt['pillar.get']('cephname') -%}
{% set cluster_data = salt['pillar.get']('ceph:clusters:' + cluster ,{}) -%}
{% if cluster != '' %}

{% set host = cluster_data.cephhostname -%}
{% set mon_keyring = '/var/lib/ceph/tmp/' + cluster + '.mon.keyring' -%}
{% set monmap = '/var/lib/ceph/tmp/' + cluster + 'monmap' -%}


ceph_mon_populate__populate_mon_{{cluster}}:
  cmd.run:
    - name: |
        ceph-mon --cluster {{ cluster }} \
                 --mkfs -i {{ host }} \
                 --monmap {{ monmap }} \
                 --keyring {{ mon_keyring }}
    - unless: test -d /var/lib/ceph/mon/{{ cluster }}-{{ host }}
    - require:
      - file: ceph_mon_populate__file_/var/lib/ceph/mon

ceph_mon_populate__file_/var/lib/ceph/mon/{{ cluster }}-{{ host }}/done:
  file.touch: 
    - name: /var/lib/ceph/mon/{{ cluster }}-{{ host }}/done
    - unless: test -f /var/lib/ceph/mon/{{ cluster }}-{{ host }}/done 
    - require: 
      - cmd: ceph_mon_populate__populate_mon_{{cluster}}

ceph_mon_populate__file_/var/lib/ceph/mon/{{ cluster }}-{{ host }}/sysvinit:
  file.touch: 
    - name: /var/lib/ceph/mon/{{ cluster }}-{{ host }}/sysvinit
    - unless: test -f /var/lib/ceph/mon/{{ cluster }}-{{ host }}/sysvinit 
    - require: 
      - cmd: ceph_mon_populate__populate_mon_{{cluster}}

{% endif -%}
