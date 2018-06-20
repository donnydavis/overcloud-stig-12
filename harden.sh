cp overcloud-hardened-full.qcow2 overcloud-full-orig.qcow2
mv overcloud-hardened-full.qcow2 overcloud-full.qcow2
export image=overcloud-full.qcow2
echo "#############################"
echo "# Hardening Overcloud Image #"
echo "#############################"
virt-customize -a $image --upload overcloud-remediation.sh:/opt
virt-customize -v -a $image --run-command 'chmod +x /opt/overcloud-remediation.sh' --run-command '/opt/overcloud-remediation.sh'
virt-customize -a $image --delete '/opt/overcloud-remediation.sh' --selinux-relabel
echo "######################################"
echo "# Uploading Hardened Image to Glance #"
echo "######################################"
source ~/stackrc
openstack overcloud plan delete overcloud
for i in $(openstack image list |grep overcloud |awk '{print $2}'); do openstack image delete $i ; done
openstack overcloud image upload --whole-disk --image-path $(pwd)
openstack baremetal configure boot
echo "#################################"
echo "# Your Image is ready to deploy #"
echo "#################################"
