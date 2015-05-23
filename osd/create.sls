ceph_osd_create__file_/var/lib/ceph/osd:
  file.directory:
    - name: /var/lib/ceph/osd
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

{% set cluster = salt['pillar.get']('cephname') -%}
{% set cluster_data = salt['pillar.get']('ceph:clusters:' + cluster ,{}) -%}
{% if cluster != '' %}

{% set bootstrap_osd_keyring = '/var/lib/ceph/bootstrap-osd/' + cluster + '.keyring' -%}
{% set fsid = cluster_data.global.fsid -%}

{% for osddev, osddev_data in cluster_data.osd.osddevs.items()|sort -%}

ceph_osd_create__disk_prepare_{{cluster}}_{{osddev}}:
  cmd.run:
    - unless: test -f {{osddev}}/fsid
    - require: 
      - file: ceph_osd_create__file_/var/lib/ceph/osd
    - require_in:
      - ceph_osd_create__disk_activate_{{cluster}}_{{osddev}}
    - name: |
        ceph-disk prepare --cluster {{ cluster }} \
                          --cluster-uuid {{ fsid }} \
{% if osddev_data.osduuid is defined and osddev_data.osduuid != ""                  %}                          --osd-uuid {{ osddev_data.osduuid }} \
{%endif%}{% if osddev_data.journaluuid is defined and osddev_data.journaluuid != "" %}                          --journal-uuid {{ osddev_data.journaluuid }} \
{%endif%}{% if osddev_data.fstype is defined and osddev_data.fstype != ""           %}                          --fs-type {{ osddev_data.fstype }} \
{%endif                                                                             %}                          {{ osddev }} 

{% if osddev_data.journaldev is defined and osddev_data.journaldev != "" %}
ceph_osd_create__journal_create_{{cluster}}_{{osddev}}:
  cmd.run:
    - name: ln -s {{ osddev_data.journaldev }} {{osddev}}/journal
    - onlyif: test -d {{osddev}} && test -f {{osddev}}/fsid
    - unless: test -L {{osddev}}/journal
    - require: 
      - cmd: ceph_osd_create__disk_prepare_{{cluster}}_{{osddev}} 
    - require_in:
      - ceph_osd_create__disk_activate_{{cluster}}_{{osddev}}

{% endif %}

ceph_osd_create__disk_activate_{{cluster}}_{{osddev}}:
  cmd.run:
    - name: |
        ceph-disk activate \
                           --mark-init sysvinit  \
                           {{ osddev }} 
    - unless: test -f {{ osddev }}/superblock
    - timeout: 60

{% endfor -%}

{% endif -%}
