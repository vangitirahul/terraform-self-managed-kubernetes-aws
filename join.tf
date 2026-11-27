resource "terraform_data" "worker_join" {
  count = var.worker_count

  triggers_replace = [
    aws_instance.master.id,
    aws_instance.worker[count.index].id
  ]

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]

    command = "bash scripts/join-worker.sh"

    environment = {
      MASTER_IP = aws_instance.master.public_ip
      WORKER_IP = aws_instance.worker[count.index].public_ip
      KEY_PATH  = var.private_key_path
    }
  }

  depends_on = [
    aws_instance.master,
    aws_instance.worker
  ]
}
