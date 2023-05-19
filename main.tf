// Para invocar a mis modulos
module "vpc" {
  source             = "./modules/network"
  vpc_cidr           = var.vpc_module["vpc_cidr"]
  environment        = var.vpc_module["environment"]
  if_private_subnets = var.vpc_module["if_private_subnets"]
  test               = "asd"
}

module "launch_template" {
  source        = "./modules/launch_templates"
  vpc_id        = module.vpc.vpc_id
  instance_size = var.launch_template_module["instance_size"]
  disk_size     = var.launch_template_module["disk_size"]
  ami           = var.launch_template_module["ami"]
  project_name  = var.project_name
}

module "asg" {
  source       = "./modules/asg"
  lc_id        = module.launch_template.lc_id
  subnets      = module.vpc.private_subnets
  project_name = var.project_name
}
