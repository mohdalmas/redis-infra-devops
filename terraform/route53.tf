
resource "aws_route53_zone" "devops" {
  name = "devops.com"
  vpc {
    vpc_id = aws_vpc.main.id
  }
}