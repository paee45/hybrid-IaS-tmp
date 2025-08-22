provider "local" {
    version = "~> 2.1"
}

provider "null" {
    version = "~> 3.0"
}

resource "null_resource" "install_k3s_control_plane" {
    provisioner "local-exec" {
        command = <<EOT
            docker run -d --privileged --name k3s-server \
                -p 6443:6443 -p 80:80 -p 443:443 \
                rancher/k3s:v1.21.4-k3s1 server

            docker exec k3s-server sh -c "
                curl -sfL https://get.k3s.io | sh -
            "
        EOT
    }
}

resource "null_resource" "install_k3s_worker" {
    count = 3
    depends_on = [null_resource.install_k3s_control_plane]

    provisioner "local-exec" {
        command = <<EOT
            docker run -d --privileged --name k3s-agent-${count.index} \
                --link k3s-server:k3s-server \
                rancher/k3s:v1.21.4-k3s1 agent \
                --server https://k3s-server:6443 \
                --token $(docker exec k3s-server cat /var/lib/rancher/k3s/server/node-token)
        EOT
    }
}

resource "null_resource" "install_kubernetes_dashboard" {
    depends_on = [null_resource.install_k3s_control_plane]

    provisioner "local-exec" {
        command = <<EOT
            kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.2.0/aio/deploy/recommended.yaml

            kubectl create serviceaccount dashboard-admin-sa -n kubernetes-dashboard
            kubectl create clusterrolebinding dashboard-admin-sa --clusterrole=cluster-admin --serviceaccount=kubernetes-dashboard:dashboard-admin-sa
        EOT
    }
}

output "docker_version" {
    value = "K3s with 1 control plane and 3 worker nodes have been installed."
}

output "dashboard_url" {
    value = "http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"
}

output "dashboard_token_command" {
    value = "kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get sa/dashboard-admin-sa -o jsonpath='{.secrets[0].name}') -o go-template='{{index .data \"token\" | base64decode}}'"
}
