output "alb_dns_name" {
  value = aws_lb.app.dns_name
}

output "waf_web_acl_arn" {
  value = aws_wafv2_web_acl.this.arn
}

output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "target_group_arn" {
  value = aws_lb_target_group.app.arn
}
