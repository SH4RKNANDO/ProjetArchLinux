#!/bin/bash

echo -e "\n Restore the FS SELINUX \n"
restorecon -rv /

echo -e "\n AUTOLABELING SELINUX \n"
cat <<EOF > requiredmod.te

module requiredmod 1.0;

require {
        type devpts_t;
        type kernel_t;
        type device_t;
        type var_run_t;
        type udev_t;
        type hugetlbfs_t;
        type udev_tbl_t;
        type tmpfs_t;
        class sock_file write;
        class unix_stream_socket { read write ioctl };
        class capability2 block_suspend;
        class dir { write add_name };
        class filesystem associate;
}

#============= devpts_t ==============
allow devpts_t device_t:filesystem associate;

#============= hugetlbfs_t ==============
allow hugetlbfs_t device_t:filesystem associate;

#============= kernel_t ==============
allow kernel_t self:capability2 block_suspend;

#============= tmpfs_t ==============
allow tmpfs_t device_t:filesystem associate;

#============= udev_t ==============
allow udev_t kernel_t:unix_stream_socket { read write ioctl };
allow udev_t udev_tbl_t:dir { write add_name };
allow udev_t var_run_t:sock_file write;

EOF

echo -e "\n AUTOLABELING SELINUX \n"
checkmodule -m -o requiredmod.mod requiredmod.te
semodule_package -o requiredmod.pp -m requiredmod.mod
semodule -i requiredmod.pp

