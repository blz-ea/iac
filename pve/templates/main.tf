resource "null_resource" "depends_on" {
  triggers = {
    depends_on = "${join("", var.dependencies)}"
  }
}

resource "null_resource" "packer_centos_7" {

	provisioner "local-exec" {
		command     = "packer build ${path.module}/centos-7"
	}

	triggers = {
		config 			    = yamlencode(var.templates.centos.7)
    sources_hash    = sha1(file("${path.module}/centos-7/sources.pkr.hcl"))
    http_seed_hash  = sha1(file("${path.module}/centos-7/http/preseed.cfg"))
	}

  depends_on = [
    null_resource.depends_on
  ]

}

resource "null_resource" "packer_ubuntu_bionic" {

	provisioner "local-exec" {
		command     = "packer build ${path.module}/ubuntu-18.04"
	}

	triggers = {
		config 			    = yamlencode(var.templates.ubuntu.bionic)
    sources_hash    = sha1(file("${path.module}/ubuntu-18.04/sources.pkr.hcl"))
    http_seed_hash  = sha1(file("${path.module}/ubuntu-18.04/http/preseed.cfg"))
	}

  depends_on = [
    null_resource.depends_on
  ]

}
