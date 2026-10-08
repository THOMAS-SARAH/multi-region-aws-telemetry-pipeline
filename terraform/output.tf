output "virginia_worker_public_ip" {
  value = aws_instance.worker_virginia.public_ip
}

output "mumbai_worker_public_ip" {
  value = aws_instance.worker_mumbai.public_ip
}

output "prometheus_scrape_targets" {
  value = [
    "${aws_instance.worker_virginia.public_ip}:9100",
    "${aws_instance.worker_mumbai.public_ip}:9100"
  ]
}
