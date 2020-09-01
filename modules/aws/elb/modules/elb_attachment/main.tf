resource "aws_elb_attachment" "default" {
  count = var.create_attachment ? var.number_of_instances : 0

  elb      = var.elb
  instance = element(var.instances, count.index)
}
