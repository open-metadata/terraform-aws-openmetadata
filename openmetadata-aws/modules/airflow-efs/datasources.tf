data "aws_subnet" "this" {
  for_each = toset(var.subnet_ids)

  vpc_id = var.vpc_id
  id     = each.value
}
