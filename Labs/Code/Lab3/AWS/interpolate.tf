output "EC2_Public_IP" {
    description = "The public IP address of my_ec2"
    value = "The public id of my vm is ${aws_instance.my_ec2.public_ip} "
}
output "VPC_id"  {
    description = "The id of the default VPC"
    value = "${data.aws_vpc.default_vpc.id} is the id of the default VPC"    
}

output "S3_ARN" {
    description = "ARN of the S3 bucket"
    value = "${aws_s3_bucket.my_bucket.arn} is the arn of the bucket ${aws_s3_bucket.my_bucket.bucket}"
}