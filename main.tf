resource "aws_s3_bucket" "terraform_state" {
  bucket = var.terraform_state_bucket_name
  tags = { Name = "terraform-state-backend", Environment = var.environment, Owner = var.owner }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration { status = "Enabled" }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.terraform_state.id
  rule { apply_server_side_encryption_by_default { sse_algorithm = "AES256" } }
}

resource "aws_s3_bucket" "replica" {
  provider = aws.replica
  bucket   = "${var.terraform_state_bucket_name}-replica"
}
resource "aws_s3_bucket_versioning" "replica" {
  provider = aws.replica
  bucket   = aws_s3_bucket.replica.id
  versioning_configuration { status = "Enabled" }
}
resource "aws_s3_bucket_replication_configuration" "replication" {
  depends_on = [aws_s3_bucket_versioning.versioning]
  role   = aws_iam_role.replication.arn
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    id     = "StateReplication"
    status = "Enabled"
    destination { bucket = aws_s3_bucket.replica.arn, storage_class = "STANDARD_IA" }
  }
}
