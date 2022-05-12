output "alb_dns_name" {
  value       = "aws_lb.my_server-lb.lb_dns_name"
  description = "The domain name of the load balancer"
}

output "server_public_ip" {
  value = aws_eip.dev_eip.public_ip
}