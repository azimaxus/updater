#!/bin/bash
# Updated BBR TCP Congestion Control Script
# Supports modern Linux kernels with BBR v2 and v3

# Updated BBR+ repository URLs
GIT_CMD="https://github.com/UJX6N/bbrplus-6.1/releases/download/6.1.38-bbrplus/"
FALLBACK_URL="https://github.com/ylx2016/Linux-NetSpeed/releases/latest/download/"

detect_kernel_version() {
    KERNEL_VERSION=$(uname -r | cut -d. -f1,2)
    KERNEL_MAJOR=$(echo $KERNEL_VERSION | cut -d. -f1)
    KERNEL_MINOR=$(echo $KERNEL_VERSION | cut -d. -f2)
}

startbbr() {
    detect_kernel_version
    
    # For kernel 5.4+ use BBR v2/v3 optimizations
    if [[ $KERNEL_MAJOR -ge 5 ]] && [[ $KERNEL_MINOR -ge 4 ]]; then
        echo "# BBR v2/v3 optimized settings for kernel $KERNEL_VERSION" >> /etc/sysctl.conf
        echo "net.core.default_qdisc=fq_codel" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_notsent_lowat=16384" >> /etc/sysctl.conf
    elif [[ $KERNEL_MAJOR -ge 5 ]]; then
        echo "# BBR v2 settings for kernel $KERNEL_VERSION" >> /etc/sysctl.conf
        echo "net.core.default_qdisc=cake" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
        echo "net.ipv4.icmp_echo_ignore_all = 0" >>/etc/sysctl.conf
        echo "net.ipv4.icmp_echo_ignore_broadcasts = 1" >>/etc/sysctl.conf
        echo "net.ipv4.icmp_ignore_bogus_error_responses = 1" >>/etc/sysctl.conf
        echo "fs.file-max = 1000000" >>/etc/sysctl.conf
        echo "fs.inotify.max_user_instances = 8192" >>/etc/sysctl.conf
        echo "net.ipv4.tcp_tw_reuse = 1" >>/etc/sysctl.conf
        echo "net.ipv4.ip_local_port_range = 1024 65535" >>/etc/sysctl.conf
        echo "net.ipv4.tcp_rmem = 16384 262144 8388608" >>/etc/sysctl.conf
        echo "net.ipv4.tcp_wmem = 32768 524288 16777216" >>/etc/sysctl.conf
        echo "net.core.somaxconn = 8192" >>/etc/sysctl.conf
        echo "net.core.rmem_max = 16777216" >>/etc/sysctl.conf
        echo "net.core.wmem_max = 16777216" >>/etc/sysctl.conf
        echo "net.core.wmem_default = 2097152" >>/etc/sysctl.conf
        echo "net.ipv4.tcp_max_tw_buckets = 5000" >>/etc/sysctl.conf
        echo "net.ipv4.tcp_max_syn_backlog = 10240" >>/etc/sysctl.conf
        echo "net.core.netdev_max_backlog = 10240" >>/etc/sysctl.conf
        echo "net.ipv4.tcp_slow_start_after_idle = 0" >>/etc/sysctl.conf
        echo "net.ipv4.ip_forward = 1" >>/etc/sysctl.conf
        echo "net.netfilter.nf_conntrack_icmp_timeout=10" >>/etc/sysctl.conf
        echo "net.netfilter.nf_conntrack_tcp_timeout_close=10" >>/etc/sysctl.conf
        echo "net.netfilter.nf_conntrack_tcp_timeout_close_wait=10" >>/etc/sysctl.conf
        echo "net.netfilter.nf_conntrack_tcp_timeout_established=600" >>/etc/sysctl.conf
        echo "net.netfilter.nf_conntrack_tcp_timeout_fin_wait=10" >>/etc/sysctl.conf
    else
	    echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
	    echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
        echo "net.ipv4.icmp_echo_ignore_all = 0" >>/etc/sysctl.conf
        echo "net.ipv4.icmp_echo_ignore_broadcasts = 1" >>/etc/sysctl.conf
        echo "net.ipv4.icmp_ignore_bogus_error_responses = 1" >>/etc/sysctl.conf
        echo "fs.file-max = 1000000" >>/etc/sysctl.conf
        echo "fs.inotify.max_user_instances = 8192" >>/etc/sysctl.conf
        echo "net.ipv4.tcp_tw_reuse = 1" >>/etc/sysctl.conf
        echo "net.ipv4.ip_local_port_range = 1024 65535" >>/etc/sysctl.conf
        echo "net.ipv4.tcp_rmem = 16384 262144 8388608" >>/etc/sysctl.conf
        echo "net.ipv4.tcp_wmem = 32768 524288 16777216" >>/etc/sysctl.conf
        echo "net.core.somaxconn = 8192" >>/etc/sysctl.conf
        echo "net.core.rmem_max = 16777216" >>/etc/sysctl.conf
        echo "net.core.wmem_max = 16777216" >>/etc/sysctl.conf
        echo "net.core.wmem_default = 2097152" >>/etc/sysctl.conf
        echo "net.ipv4.tcp_max_tw_buckets = 5000" >>/etc/sysctl.conf
        echo "net.ipv4.tcp_max_syn_backlog = 10240" >>/etc/sysctl.conf
        echo "net.core.netdev_max_backlog = 10240" >>/etc/sysctl.conf
        echo "net.ipv4.tcp_slow_start_after_idle = 0" >>/etc/sysctl.conf
        echo "net.ipv4.ip_forward = 1" >>/etc/sysctl.conf
        echo "net.netfilter.nf_conntrack_max = 524288" >>/etc/sysctl.conf
        echo "net.netfilter.nf_conntrack_icmp_timeout=10" >>/etc/sysctl.conf
        echo "net.netfilter.nf_conntrack_tcp_timeout_close=10" >>/etc/sysctl.conf
        echo "net.netfilter.nf_conntrack_tcp_timeout_close_wait=10" >>/etc/sysctl.conf
        echo "net.netfilter.nf_conntrack_tcp_timeout_established=600" >>/etc/sysctl.conf
        echo "net.netfilter.nf_conntrack_tcp_timeout_fin_wait=10" >>/etc/sysctl.conf
    fi
}
installbbrplus(){
    echo "Installing BBR+ kernel..."
    cd /tmp
    
    # Download latest BBR+ kernel (updated URLs)
    echo "Downloading BBR+ kernel packages..."
    
    # Try primary URL first
    if ! wget -N --no-check-certificate https://github.com/UJX6N/bbrplus-6.1/releases/download/6.1.38-bbrplus/linux-image-6.1.38-bbrplus_6.1.38-bbrplus-1_amd64.deb \
        -O bbrplus_6.1.38_amd64.deb >/dev/null 2>&1; then
        echo "Primary URL failed, trying fallback..."
        wget -N --no-check-certificate ${FALLBACK_URL}linux-image-bbrplus_amd64.deb \
            -O bbrplus_6.1.38_amd64.deb >/dev/null 2>&1
    fi
    
    if ! wget -N --no-check-certificate https://github.com/UJX6N/bbrplus-6.1/releases/download/6.1.38-bbrplus/linux-headers-6.1.38-bbrplus_6.1.38-bbrplus-1_amd64.deb \
        -O bbrplus_6.1.38-headers_amd64.deb >/dev/null 2>&1; then
        echo "Primary headers URL failed, trying fallback..."
        wget -N --no-check-certificate ${FALLBACK_URL}linux-headers-bbrplus_amd64.deb \
            -O bbrplus_6.1.38-headers_amd64.deb >/dev/null 2>&1
    fi
    
    # Install packages
    if dpkg -i bbrplus_6.1.38_amd64.deb >/dev/null 2>&1; then
        echo "BBR+ kernel installed successfully"
    else
        echo "Failed to install BBR+ kernel"
        return 1
    fi
    
    if dpkg -i bbrplus_6.1.38-headers_amd64.deb >/dev/null 2>&1; then
        echo "BBR+ headers installed successfully"
    else
        echo "Warning: Failed to install BBR+ headers"
    fi
    
    # Clean up
    rm -f bbrplus_6.1.38_amd64.deb bbrplus_6.1.38-headers_amd64.deb
}

apply_sysctl() {
    echo "Applying sysctl settings..."
    sysctl -p
    echo "BBR configuration applied. Reboot required for kernel changes."
}
# Main execution
echo "Starting BBR configuration..."
startbbr
apply_sysctl

# Uncomment the line below to install BBR+ kernel (requires reboot)
#installbbrplus
