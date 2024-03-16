output "EC2_Ami" {
  description = "The aim of my_vm"
  value       = aws_instance.my_ec2.ami
}
output "EC2_Instance" {
  description = "The instance tyoe of my_vm"
  value       = aws_instance.my_ec2.instance_type
}

output "S3_ARN" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.my_bucket.arn
}