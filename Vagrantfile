# -*- mode: ruby -*-
# vi: set ft=ruby :

# 安装必备插件：
# 1. 配置代理，需要 vagrant-proxyconf 插件
required_plugins = %w(vagrant-proxyconf)
plugins_to_install = required_plugins.select { |plugin| not Vagrant.has_plugin? plugin }
if not plugins_to_install.empty?
  puts "Installing plugins: #{plugins_to_install.join(' ')}"
  if system "vagrant plugin install #{plugins_to_install.join(' ')}"
    exec "vagrant #{ARGV.join(' ')}"
  else
    abort "Installation of one or more plugins has failed. Aborting."
  end
end

ENV["LC_ALL"] = "en_US.UTF-8"

# 
$num_instances = 3
$instance_name_prefix = "node"
$vm_memory = 1024
$vm_cpus = 2
$forwarded_ports = {}

Vagrant.configure("2") do |config|

  config.ssh.forward_agent = true

  config.vm.box = "centos/7"

  config.vm.provider :virtualbox do |vb|
    vb.memory = $vm_memory
    vb.cpus = $vm_cpus
  end

  # 设置代理
  #config.proxy.http     = "http://10.0.2.2:8080"
  #config.proxy.https    = "http://10.0.2.2:8080"
  #config.proxy.no_proxy = "localhost,127.0.0.1,.example.com"

  # http://tmatilai.github.io/vagrant-proxyconf/
  # 代理配置会重启 Docker 服务，但其依赖的服务并未启动导致失败
  # 去掉对 Docker 执行配置，需要时在 config.vm.provision 修改 /etc/sysconfig/docker 
  #config.proxy.enabled = { docker: false }

  config.vm.provision "shell", inline: <<-SHELL
set -xe
export PS4='+[$LINENO]'

# no_proxy
cat >/etc/profile.d/zzz_no_proxy.sh <<\EOF
# Named 'zzz_no_proxy.sh', so it will be loaded finally, and overwrite Env variable 'no_proxy'.
export no_proxy=\\$(echo 172.17.0.{1..255} | sed "s/ /,/g")
export no_proxy=\\${no_proxy},localhost,127.0.0.1,.example.com
EOF
source /etc/profile.d/zzz_no_proxy.sh &>/dev/null

# 可能需要配置 Proxy 的 CA 证书
cat >>/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem <<\EOF

EOF

# 禁用 selinux
setenforce Permissive || true
sed -i 's|^SELINUX=.*|SELINUX=disabled|' /etc/selinux/config

# 关闭 swap
swapoff -a
sed -i '/swap/{ s|^|#| }' /etc/fstab

  SHELL

  # 根据节点的主机名和IP，生成 ETCD_INITIAL_CLUSTER
  cluster = Array.new
  (1..$num_instances).each do |i|
    cluster.push("%s-%02d=http://172.17.0.#{i+100}:2380" % [$instance_name_prefix, i, i])
  end
  ETCD_INITIAL_CLUSTER = cluster.join(",")

  (1..$num_instances).each do |i|
    config.vm.define vm_name = "%s-%02d" % [$instance_name_prefix, i] do |node|
      node.vm.hostname = vm_name

      ip = "172.17.0.#{i+100}"
      node.vm.network :private_network, ip: ip

      # 注：不管 node.vm.provision 定义先后，都在 config.vm.provision 之后执行 -- Vagrant enforces ordering outside-in
      node.vm.provision "shell" do |s|
        s.inline = <<-SHELL
set -xe
export PS4='+[$LINENO]'

bash /vagrant/provision/etcd.sh
bash /vagrant/provision/etcd_config.sh "$2" "$3" "$4"
bash /vagrant/provision/flannel.sh
bash /vagrant/provision/docker.sh
systemctl start etcd flanneld docker &

bash /vagrant/provision/kubernetes.sh
bash /vagrant/provision/kubernetes_node.sh
systemctl start kube-proxy kubelet &

if [[ "$1" == "1" ]]; then
  bash /vagrant/provision/kubernetes_client.sh
  bash /vagrant/provision/kubernetes_master.sh
  systemctl start kube-apiserver kube-controller-manager kube-scheduler &
fi

        SHELL
        s.args = [i, vm_name, ip, ETCD_INITIAL_CLUSTER]    # 脚本中使用 $1, $2, $3... 读取
      end
    end
  end
end
