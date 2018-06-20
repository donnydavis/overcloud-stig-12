#!/bin/bash
echo "#############################"
echo "# Building Partitioned Image#"
echo "#############################"
export DIB_LOCAL_IMAGE=./rhel-server-7.5-x86_64-kvm.qcow2
export REG_METHOD=portal
export REG_USER="user.name"
export REG_PASSWORD="portal_password"
export REG_POOL_ID="pool_id_that_has_the_openstacks"
export REG_REPOS="rhel-7-server-rpms \
    rhel-7-server-extras-rpms \
    rhel-ha-for-rhel-7-server-rpms \
    rhel-7-server-optional-rpms \
    rhel-7-server-openstack-12-rpms
    rhel-7-server-rhceph-2-tools-rpms \
    rhel-7-server-rhceph-2-mon-rpms \
    rhel-7-server-rhceph-2-osd-rpms"
export DIB_BLOCK_DEVICE_CONFIG='''
- local_loop:
    name: image0
- partitioning:
    base: image0
    label: mbr
    partitions:
      - name: root
        flags: [ boot,primary ]
        size: 5G
- lvm:
    name: lvm
    base: [ root ]
    pvs:
        - name: pv
          base: root
          options: [ "--force" ]
    vgs:
        - name: vg
          base: [ "pv" ]
          options: [ "--force" ]
    lvs:
        - name: lv_root
          base: vg
          extents: 34%VG
        - name: lv_tmp
          base: vg
          extents: 1%VG
        - name: lv_var
          base: vg
          extents: 60%VG
        - name: lv_log
          base: vg
          extents: 2%VG
        - name: lv_audit
          base: vg
          extents: 2%VG
        - name: lv_home
          base: vg
          extents: 1%VG
- mkfs:
    name: fs_root
    base: lv_root
    type: xfs
    label: "img-rootfs"
    mount:
        mount_point: /
        fstab:
            options: "rw,relatime"
            fck-passno: 1
- mkfs:
    name: fs_tmp
    base: lv_tmp
    type: xfs
    mount:
        mount_point: /tmp
        fstab:
            options: "rw,nosuid,nodev,noexec,relatime"
- mkfs:
    name: fs_var
    base: lv_var
    type: xfs
    mount:
        mount_point: /var
        fstab:
            options: "rw,relatime"
- mkfs:
    name: fs_log
    base: lv_log
    type: xfs
    mount:
        mount_point: /var/log
        fstab:
            options: "rw,relatime"
- mkfs:
    name: fs_audit
    base: lv_audit
    type: xfs
    mount:
        mount_point: /var/log/audit
        fstab:
            options: "rw,relatime"
- mkfs:
    name: fs_home
    base: lv_home
    type: xfs
    mount:
        mount_point: /home
        fstab:
            options: "rw,nosuid,nodev,relatime"

'''
openstack overcloud image build \
--image-name overcloud-hardened-full \
--config-file overcloud-hardened-images-custom.yaml \
--config-file /usr/share/openstack-tripleo-common/image-yaml/overcloud-hardened-images-rhel7.yaml \
--verbose
