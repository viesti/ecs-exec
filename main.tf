resource "aws_ecs_cluster" "main" {
  name = "main"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_iam_role" "ecs-exec" {
  name = "ecs-exec"
  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Principal =  {
            Service = [
              "ecs-tasks.amazonaws.com"
            ]
          }
         Action = "sts:AssumeRole"
        }
      ]
    })

  inline_policy {
    name = "ecs_exec"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "ssmmessages:CreateControlChannel",
            "ssmmessages:CreateDataChannel",
            "ssmmessages:OpenControlChannel",
            "ssmmessages:OpenDataChannel"
          ],
          Resource = "*"
        }]})
  }
}

resource "aws_ecs_task_definition" "ecs-exec" {
  family = "ecs-exec"
  task_role_arn = aws_iam_role.ecs-exec.arn
  network_mode = "awsvpc"
  requires_compatibilities = [
    "EC2",
    "FARGATE"
  ]
  cpu = ".25 vcpu"
  memory = ".5 gb"
  container_definitions = jsonencode ([
    {
      name = "amazon-linux"
      image = "amazonlinux:latest"
      essential = true
      command = ["sleep","3600"]
      linuxParameters = {
        initProcessEnabled = true
      }
    }
  ])
}

resource "aws_ecs_service" "ecs-exec" {
  name = "ecs-exec"
  cluster = aws_ecs_cluster.main.arn

  depends_on = [aws_iam_role.ecs-exec]

  task_definition = aws_ecs_task_definition.ecs-exec.arn
  desired_count = 1
  launch_type = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets = data.aws_subnets.default.ids
    security_groups = [aws_security_group.ecs-exec.id]
    assign_public_ip = true
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "ecs-exec" {
  name = "ecs-exec"
  vpc_id = data.aws_vpc.default.id

  egress {
    description = "Outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
