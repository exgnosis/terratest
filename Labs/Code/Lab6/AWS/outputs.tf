output  "Neo" {
    value = aws_instance.my_ec2[0].tags.Name
    description = "Outputs a single string"
}
output  "Everyone" {
    value = aws_instance.my_ec2[*].tags.Name
    description = "Outputs a list of strings"
}