# Multi-Region AWS Infrastructure & Telemetry Pipeline

This repository contains an Infrastructure as Code (IaC) setup and observability pipeline deploying multi-region AWS worker nodes running **Node Exporter** with automated **Prometheus** metric scraping[cite: 4, 5].

---

##  Architecture Overview

- **Infrastructure as Code (IaC):** Terraform provisions two Ubuntu EC2 worker nodes across distinct AWS regions (`us-east-1` in Virginia and `ap-south-1` in Mumbai) with custom security group configurations.
- **Metric Telemetry:** Bootstrapped via `user_data` scripts, each EC2 instance automatically installs, configures, and runs **Node Exporter (v1.8.2)** as a persistent `systemd` service listening on port `9100`.
- **Centralized Monitoring:** A Prometheus instance scrapes CPU, memory utilization, and network performance metrics from both target nodes across regions.

---

##  Repository Structure

```text
.
├── terraform/
│   ├── providers.tf      # Multi-region AWS provider setup
│   ├── main.tf           # EC2, Security Groups, and user_data bootstrap scripts
│   └── outputs.tf        # Public IP and Prometheus scrape target outputs
├── prometheus/
│   └── prometheus.yml    # Prometheus scrape config targeting worker nodes
├── .gitignore
└── README.md
