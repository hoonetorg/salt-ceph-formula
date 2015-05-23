ceph_mds__file_/var/lib/ceph/mds:
  file.directory:
    - name: /var/lib/ceph/mds
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
    - require:
      - cmd: ceph_server__available

{% set cluster = salt['pillar.get']('cephname') -%}
{% set cluster_data = salt['pillar.get']('ceph:clusters:' + cluster ,{}) -%}
{% if cluster != '' %}

{% set bootstrap_mds_keyring = '/var/lib/ceph/bootstrap-mds/' + cluster + '.keyring' -%}

{#
# create
# old# http://www.sebastien-han.fr/blog/2013/05/13/deploy-a-ceph-mds-server/
# ensure that /var/lib/ceph/bootstrap-mds/cs.keyring exist

#deploy
mkdir -p /var/lib/ceph/mds/cs-0
ceph --cluster cs --name client.bootstrap-mds --keyring /var/lib/ceph/bootstrap-mds/cs.keyring auth get-or-create mds.0  osd 'allow rwx' mds 'allow' mon 'allow profile mds' -o /var/lib/ceph/mds/cs-0/keyring
touch /var/lib/ceph/mds/cs-0/done
touch /var/lib/ceph/mds/cs-0/sysvinit

#start
systemctl restart cs.service


#create cephfs pools (data, metadata)
ceph --cluster cs osd pool create cephfs_data 256
ceph --cluster cs osd pool create cephfs_metadata 256


#create cephfs fs
ceph --cluster cs fs new hoonet cephfs_data cephfs_metadata



#mount
#http://ceph.com/docs/master/cephfs/kernel/

mkdir -p /cephfs
mount -t ceph -o name=admin,secret=<cs.client.admin.keyring>  a-ceph-mon-server1cs,a-ceph-mon-server2cs,a-ceph-mon-server3cs:/ /cephfs


#remove
#http://lists.ceph.com/pipermail/ceph-users-ceph.com/2015-January/045649.html

#remove md
/etc/init.d/cs stop mds
ceph --cluster cs mds fail 0
#ceph --cluster cs mds rmfailed 0
#ceph --cluster cs mds rm 0 mds.0
rm -R /var/lib/ceph/mds/cs-0
systemctl restart cs

#remove fs and pools
ceph --cluster cs fs ls
ceph --cluster cs fs rm hoonet --yes-i-really-mean-it
ceph --cluster cs osd pool delete cephfs_data cephfs_data --yes-i-really-really-mean-it
ceph --cluster cs osd pool delete cephfs_metadata cephfs_metadata --yes-i-really-really-mean-it


#status, maintain
ceph --cluster cs mds stat
ceph --cluster cs fs ls

#}

#ceph_mds__create_mdss_{{cluster}}_{{mdsnum}}:
ceph_mds__create_mdss_{{cluster}}:
  cmd.run:
    - unless: ceph --cluster {{cluster}} mds ls|egrep "^{{cluster_data.mds.create_mdss}}$"
    - name: ceph --cluster {{ cluster }} mds create

{% endif -%}
