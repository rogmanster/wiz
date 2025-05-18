data "aws_iam_policy_document" "s3_backup_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.oidc_provider, "https://", "")}:sub"
      values   = ["system:serviceaccount:default:mongodb-backup-sa"]
    }
  }
}

resource "aws_iam_role" "s3_backup" {
  name               = "s3-backup-role"
  assume_role_policy = data.aws_iam_policy_document.s3_backup_assume_role.json
}

resource "aws_iam_role_policy" "s3_backup_policy" {
  name = "s3-backup-policy"
  role = aws_iam_role.s3_backup.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ],
        Resource = [
          "arn:aws:s3:::rogman-tasky-backups/*"
        ]
      }
    ]
  })
}

resource "kubernetes_service_account" "mongodb_backup" {
  metadata {
    name      = "mongodb-backup-sa"
    namespace = "default"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.s3_backup.arn
    }
  }
}
