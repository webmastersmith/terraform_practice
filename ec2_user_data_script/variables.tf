variable "my_ip" {
  description = "Home IP"
  type        = string
  # default     = "0.0.0.0/32" # CHANGE ME THEN UNCOMMENT ME!
}
variable "ec2_id" {
  description = "AWS EC2 ID"
  type        = string
  default     = "ami-090fa75af13c156b4" # AWS Linux -ec2-user
  # default     = "ami-052efd3df9dad4825" # Ubuntu 22.04

}
variable "ec2_size" {
  description = "AWS EC2 Instance size"
  type        = string
  default     = "t2.micro" # CHANGE ME THEN UNCOMMENT ME!

}
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"

}
