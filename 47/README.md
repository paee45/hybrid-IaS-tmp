# 47
hybrid app/docker/bare metal on 47 infrastructure




⸻
Home Assistant Pod
Run with Deployment, PVC for config
Persistent Storage
Longhorn, NFS, or Rook-Ceph (must support RWX)
Database
PostgreSQL (in-cluster or external)
MQTT Broker
Mosquitto / EMQX in-cluster, optional clustering
Backup
Enable snapshots of the PVC or backup Postgres
Ingress
Traefik with HTTPS certs + basic auth for protection




Would you like:
	•	A K3s-ready Helm chart or Kustomize deployment for HA?
	•	A YAML template with PVC + PostgreSQL + MQTT?
	•	Or an architecture diagram for scalable smart home workloads on K3s?