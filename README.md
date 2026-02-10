# terraform-state-dr (disaster recovery)
A production-ready solution that ensures Terraform state is resilient across regions - a disaster recovery (DR)–ready backend.

Designing a Disaster-Recovery Ready Terraform Backend with Cross-Region Replication on AWS 

How I Built a Disaster-Recovery Ready Terraform State Backend with Cross-Region Replication on AWS

## Introduction  

Terraform state is the source of truth for your infrastructure. Losing it can lock you out of your AWS environment, prevent scaling, or make recovery impossible.
Most tutorials and setups store the state in a single S3 bucket. While S3 provides high durability (11 nines), this does not protect against regional outages.
As a DevOps engineer, I wanted a production-ready solution that ensures Terraform state is resilient across regions - a disaster recovery (DR)–ready backend.

## Solution Overview  

✅ I implemented an Active-Passive Cross-Region Replication (CRR) architecture using:  
✅ Primary S3 bucket: Stores Terraform state in the main region (us-east-1)  
✅ Secondary S3 bucket: DR replica in a different AWS region (us-west-2)  
✅ Versioning: All state changes are versioned for historical recovery  
✅ Encryption: Server-side encryption using AES256  
✅ State locking: Native S3 locking (Terraform ≥1.6)  
✅ Lifecycle management: Automatic cleanup of non-current versions after 30 days

This ensures that even if the primary region goes down, the Terraform state is preserved and can be recovered.

## Architecture Diagram
<img width="1457" height="779" alt="Screenshot 2026-02-11 021938" src="https://github.com/user-attachments/assets/b312f284-004b-43a3-8a66-3916a4f0a56c" />

---

Note:
IAM Role ensures replication permissions
Terraform backend points to primary bucket
Native locking prevents race conditions when multiple engineers work in parallel

---

## Key Terraform Implementation Snippets
Backend Configuration (backend.tf)
````
terraform {
  backend "s3" {
    bucket       = "tf-state-governance-demo-us-east-1"
    key          = "platform/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
````
Tip: Comment this out for the first terraform apply. After the bucket is created, uncomment it and run terraform init -migrate-state.  


## Primary Bucket with Versioning & Encryption (main.tf)
````
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.terraform_state_bucket_name
  tags = {
    Name        = "terraform-state-backend"
    Environment = var.environment
    Owner       = var.owner
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
````
## DR Bucket & Cross-Region Replication
````
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
````
---

## Execution Steps:  
1. Create all files (main.tf, provider.tf, variables.tf, outputs.tf, terraform.tfvars, backend.tf)
2. Comment out backend.tf for the first apply
3. Initialize Terraform:
````
terraform init
````
4. Plan changes:
````
terraform plan -var-file="terraform.tfvars"
````
5. Apply resources:
````
terraform apply -var-file="terraform.tfvars"
````
6. Uncomment backend.tf and migrate state:
````
terraform init -migrate-state
````
7. Verify buckets:
````
aws s3 ls s3://bucket-name-here
aws s3 ls s3://bucket-name-here-replica --region us-west-2
````
8. Optional: Destroy resources when done:
````
terraform destroy -var-file="terraform.tfvars"
````


## Benefits  

Multi-region resilience: State is recoverable even if the primary region fails
Versioning & Locking: Protects against accidental overwrites and race conditions
Enterprise-ready: Production-quality setup without needing Terraform Cloud
Easy recovery: Infrastructure state can be restored from DR bucket without manual intervention

---

## Enhancements  

Automate notifications for replication failures
Integrate with Terraform Cloud/Enterprise for team-wide locking and governance
Add state promotion scripts for disaster recovery drills

---

## Key Takeaways  

Terraform state is critical production metadata - treat it like real infrastructure
S3 CRR + Versioning + Locking = enterprise-grade resilience
Planning for failure is not optional in professional DevOps environments
<img width="1098" height="238" alt="image" src="https://github.com/user-attachments/assets/f945a39d-72c5-4ca7-a25d-80223674c591" />


## Summary:  

This project shows real DevOps skills, production awareness, and architectural thinking.
