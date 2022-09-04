variable "region" {
  description = "AWS region"
  type        = string
  # default     = "us-west-1" # CHANGE ME THEN UNCOMMENT ME!
}
variable "my_home_ip" {
  description = "Your home ip. For firewall rules that allow you access to cluster"
  type        = string
  # default     = "000.000.000.000/32" # CHANGE ME THEN UNCOMMENT ME!
}
variable "user_name" {
  description = "The aws user name"
  type        = string
  # default     = "bob" # CHANGE ME THEN UNCOMMENT ME!
}
