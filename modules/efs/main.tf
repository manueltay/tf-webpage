resource "aws_autoscaling_group" "bar" {
  name                      = "${var.project_name}-asg"
  desired_capacity          = 1
  max_size                  = 1
  min_size                  = 1
  default_cooldown          = "60"
  health_check_grace_period = "600"

  launch_template {
    id      = var.lc_id
    version = "$Latest"
  }

  vpc_zone_identifier = var.subnets
}
