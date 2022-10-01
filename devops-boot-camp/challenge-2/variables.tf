variable "region" {
  type    = string
  default = "us-east-2"
}

variable "is_dns_support" {
  type    = bool
  default = false
}


variable "my_ami" {
  type = map(string)
  default = {
    "us-east-1" = "ami-097a2df4ac947655f", # ubunut
    "us-east-2" = "ami-0f924dc71d44d23e2"  # liux
  }
}

variable "my_instance" {
  type    = tuple([string, number, bool])
  default = ["t2.micro", 2, true]
}

variable "iam_users" {
  type = map(string)
  default = {
    "user1" : "test1",
    "user2" : "test2"
  }
}
