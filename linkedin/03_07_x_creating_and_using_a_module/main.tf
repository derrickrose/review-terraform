module "bucket_module" {
  source      = "./bucket_module"
  bucket_name = var.bronze_bucket_name
}

output "bucket_arn" {
    value = module.bucket_module.arn
}