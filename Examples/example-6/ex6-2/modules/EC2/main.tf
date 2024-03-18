resource "aws_instance" "alpha" {
    ami = "ami-080e1f13689e07408"
    instance_type = "t2.nano"
    tags = {
        source = "EC2 Module"
    }
}
