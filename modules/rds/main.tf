# OpenMetadata Database resources

resource "random_password" "db_password" {
  length           = 16
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  special          = true
  override_special = "#^&*()-_=+[]{}:?"
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~>6.10"

  identifier                  = var.db_config.aws.identifier
  db_name                     = var.db_config.db_name
  username                    = var.db_config.credentials.username
  password                    = try(random_password.db_password.result, null)
  manage_master_user_password = false

  engine               = "postgres"
  family               = "postgres${var.db_config.engine.version}"
  major_engine_version = var.db_config.engine.version
  instance_class       = var.db_config.aws.instance_class

  allocated_storage                   = var.db_config.storage_size
  storage_encrypted                   = true
  storage_type                        = "gp3"
  kms_key_id                          = var.kms_key_id
  copy_tags_to_snapshot               = true
  apply_immediately                   = true
  iam_database_authentication_enabled = true
  multi_az                            = var.db_config.aws.multi_az

  maintenance_window      = var.db_config.aws.maintenance_window
  backup_window           = var.db_config.aws.backup_window
  backup_retention_period = var.db_config.aws.backup_retention_period

  port                   = var.db_config.port
  vpc_security_group_ids = [module.sg_db.security_group_id]
  create_db_subnet_group = true
  subnet_ids             = var.subnet_ids

  skip_final_snapshot = var.db_config.aws.skip_final_snapshot
  deletion_protection = var.db_config.aws.deletion_protection

  parameter_group_name      = var.db_config.aws.identifier
  create_db_parameter_group = true
}

module "sg_db" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~>5.2"

  name               = "${var.db_config.aws.identifier}-db"
  description        = "Security group for the ${var.db_config.aws.identifier} RDS instance"
  vpc_id             = var.vpc_id
  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

  ingress_with_source_security_group_id = [for sg_id in var.eks_nodes_sg_ids :
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      description              = "DB from ${sg_id}"
      source_security_group_id = sg_id
    }
  ]
}

resource "kubernetes_secret_v1" "db_credentials" {

  metadata {
    name      = var.db_config.credentials.password.secret_ref
    namespace = var.namespace
  }

  data = {
    (var.db_config.credentials.password.secret_key) = random_password.db_password.result
  }
}
