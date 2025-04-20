output "master_url" {
  value = [for s in var.master_ssh : {
    name : s.name,
    url : "http://${s.ip}"
  }]
}