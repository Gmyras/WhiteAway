resource "aws_cloudwatch_log_group" "this" {
  name_prefix       = "${terraform.workspace}-hello_world-"
  retention_in_days = 1
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

# for the example sake I didnt use different versions of the container image per environment.
resource "aws_ecs_task_definition" "this" {
  family = "hello_world"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
#  task_role_arn            = "${data.aws_iam_role.ecs_task_execution_role.arn}"
  execution_role_arn       = "${data.aws_iam_role.ecs_task_execution_role.arn}"
  cpu                      = 256
  memory                   = 512

  container_definitions = <<EOF
[
  {
    "name": "hello_world",
    "image": "strm/helloworld-http",
    "cpu": 256,
    "memory": 512,
    "portMappings": [
      {
        "containerPort": 80,
        "protocol": "tcp"
      }
    ],    
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "eu-west-1",
        "awslogs-group": "${aws_cloudwatch_log_group.this.name}",
        "awslogs-stream-prefix": "ec2"
      }
    }
  }
]
EOF
}

resource "aws_ecs_service" "this" {
  name            = "hello_world"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.this.arn

  launch_type = "FARGATE"
  network_configuration {
    subnets = var.subnets_ids
    security_groups = aws_security_group.this.id
    assign_public_ip = true
  }

  desired_count = 1

  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0

  depends_on = [
    aws_security_group.this
  ]
}

resource "aws_security_group" "this" {
  name        = "hello_world-${terraform.workspace}"
  description = "Allow ALL traffic"
  vpc_id      = var.vpc_id
  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}