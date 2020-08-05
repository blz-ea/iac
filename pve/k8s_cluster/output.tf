output "k8s_config_file_path" {
  # Kubeconfig file that was create by Kubespray
  value = "${path.module}/config/admin.conf"
}