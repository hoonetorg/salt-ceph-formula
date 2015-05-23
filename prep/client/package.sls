ceph_prep_client_package__pkg_ceph-common-package:
  pkg.installed:
    - pkgs:
      - ceph-common
#{% set slsrequires =salt['pillar.get']('ceph:slsrequires', False) %}
#{% if slsrequires is defined and slsrequires %}
#    - require:
#{% for slsrequire in slsrequires %}
#      - {{slsrequire}}
#{% endfor %}
#{% endif %}
