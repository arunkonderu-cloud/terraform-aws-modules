# -----------------------------------------------------------------------------
# IAM Role Module - main.tf
# Least-privilege IAM roles with trust relationships and inline/managed policies
# -----------------------------------------------------------------------------

locals {
  common_tags = merge(var.tags, {
    Module    = "iam-role"
    ManagedBy = "terraform"
  })
}

resource "aws_iam_role" "this" {
  name                 = var.role_name
  description          = var.description
  max_session_duration = var.max_session_duration
  path                 = var.path

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = var.trust_policy_statements
  })

  tags = local.common_tags
}

# Attach AWS managed policies
resource "aws_iam_role_policy_attachment" "managed" {
  for_each = toset(var.managed_policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

# Create and attach inline policy if provided
resource "aws_iam_role_policy" "inline" {
  count = var.inline_policy != null ? 1 : 0

  name   = "${var.role_name}-inline-policy"
  role   = aws_iam_role.this.id
  policy = jsonencode(var.inline_policy)
}

# Instance profile (for EC2 roles)
resource "aws_iam_instance_profile" "this" {
  count = var.create_instance_profile ? 1 : 0

  name = var.role_name
  role = aws_iam_role.this.name

  tags = local.common_tags
}
