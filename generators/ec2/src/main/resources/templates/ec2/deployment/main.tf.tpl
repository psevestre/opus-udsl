#
# Generated code. DO NOT EDIT !!!
# This file will be overwritten every time you run the generator
# Any changes WILL BE LOST !!!
#
# Template: deployment/main.tf.tpl
#
<%
def dollar = '$'
%>


#
# Recupera AMI-ID da imagem que vamos utilizar para o deployment
#
data "aws_ami_ids" "service" {
	owners = var.ami_owner_ids
  
	filter {
	  name   = "name"
	  values = [var.ami_name]
	}
}

#
# Recupera VPCs em que o deployment ser� criado
#
data "aws_security_groups" "security_group" {
  filter {
	name   = "vpc-id"
	values = ["$dollar{var.vpc_id}"]
  }
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

#
# Launch template
#
resource "aws_launch_template" "tpl" {
  description = "Service Launch Template"
  
  name_prefix   = "ltpl_${deployment.name}_"
  image_id      =  data.aws_ami_ids.service.ids[0]
  instance_type = var.instance_type
  tag_specifications {
	  resource_type = "instance"
	  tags = {
	    deployment = "${deployment.name}"
	    application = "${env.name}"
	  }
  }
}


##
## Autoscaling Group for this deployment
##
resource "aws_autoscaling_group" "deployment" {
  desired_capacity   = var.autoscale_desired_capacity <= 0 ? 1: var.autoscale_desired_capacity 
  max_size           = var.autoscale_max_size <= 0 ? 1: var.autoscale_max_size
  min_size           = var.autoscale_min_size <= 0 ? 1: var.autoscale_min_size
  
  vpc_zone_identifier = var.ingress_subnet_ids
  default_cooldown = 30
  health_check_grace_period = 30

  launch_template {
	id      = aws_launch_template.tpl.id
	version = var.launch_template_version
  }
}

##
## Attachments
##
<%
def attachments = ec2.targetGroupsForDeployment(env,deployment)
for( int i = 0 ; i < attachments.size() ; i++ ) {
%>
resource "aws_autoscaling_attachment" "autoscale_attachment_${i}" {
  autoscaling_group_name = aws_autoscaling_group.deployment.id
  alb_target_group_arn = var.lb_target_group_arns[${i}]
}

<%
}
%>
