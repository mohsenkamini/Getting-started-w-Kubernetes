#!/bin/bash
#
#
# more info https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
#
tmp_file="/tmp/list_of_macs"
tmp_file_2="/tmp/list_of_macs_2"

for i in `cat list_of_vms| xargs ` ; do  echo -n "$i " ; ssh mohsen@$i -i /home/mohsen/.ssh/github-mohsen-local-laptop -t 'sudo find /sys/class/net -mindepth 1 -maxdepth 1 ! -name lo -printf "%P: " -execdir cat {}/address \;' ; done >  "$tmp_file"


cp "$tmp_file" "$tmp_file_2"


for i in `cat "$tmp_file_2" | awk '{print $3}' | sort -u | xargs` ; do sed -i "0,/$i/s/.* $i//" "$tmp_file_2";  done


echo "Here are the duplicate product_uuids: 
"

for i in `cat $tmp_file_2 | xargs` ; do cat "$tmp_file" | grep "$i" ; echo ""; done
