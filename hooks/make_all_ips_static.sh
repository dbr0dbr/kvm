#!/bin/bash
#add this line to /etc/libvirt/hooks/qemu:
#if [ "$2" = start ]; then nohup /etc/libvirt/hooks/make_all_ips_static.sh $@> /dev/null 2>&1 &   fi

vm_name=$1
mac=`grep 'mac addr' /etc/libvirt/qemu/$vm_name.xml |awk -F "'" '{print $2}'`

function get_ip {
ip=`arp -a |grep $mac |awk -F '(' '{print \$2}' |awk -F ')' '{print \$1}'`
if [[ $ip == '' ]]; then
  sleep 3
  get_ip $vm_name
else
  sed -i /'<\/dhcp>'/d /etc/libvirt/qemu/networks/default.xml
  sed -i /'<\/ip>'/d /etc/libvirt/qemu/networks/default.xml
  sed -i /'<\/network>'/d /etc/libvirt/qemu/networks/default.xml
  echo "      <host mac='$mac' name='$vm_name' ip='$ip'/>" >> /etc/libvirt/qemu/networks/default.xml
  echo "    </dhcp>" >> /etc/libvirt/qemu/networks/default.xml
  echo "  </ip>" >> /etc/libvirt/qemu/networks/default.xml
  echo "</network>" >> /etc/libvirt/qemu/networks/default.xml
fi
}

if grep -q $mac /etc/libvirt/qemu/networks/default.xml; then exit 0; else get_ip $vm_name; fi
