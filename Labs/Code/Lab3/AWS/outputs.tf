output "EC2_Public_IP" {
    description = "The public IP address of my_vm"
    value = aws_instance.my_ec2.public_ip
}
output "VPC_id"  {
    description = "The id of the default VPC"
    value = data.aws_vpc.default_vpc.id    
}

output "S3_ARN" {
    description = "ARN of the S3 bucket"
    value = aws_s3_bucket.my_bucket.arn
}