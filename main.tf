terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
}

resource "aws_ecr_repository" "foo" {
  name                 = "sampledocker"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecs_cluster" "foo" {
  name = "sample-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "my_task_definition" {
  family                   = "my-task"
  network_mode             = "awsvpc"
  cpu                      = "1024"
  memory                   = "2048"

  requires_compatibilities = [
    "FARGATE"
  ]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name            = "first-container"
      image           = "071045444115.dkr.ecr.us-east-1.amazonaws.com/sampledocker:latest"
      cpu             = 256
      memory          = 512
      essential       = true
      portMappings    = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    },
    {
      name            = "second-container"
      image           = "071045444115.dkr.ecr.us-east-1.amazonaws.com/sampledocker:latest"
      cpu             = 256
      memory          = 512
      essential       = true
      portMappings    = [
        {
          containerPort = 443
          hostPort      = 443
        }
      ]
    }
  ])
}

# Define the IAM policy for ECS task execution
resource "aws_iam_policy" "ecs_task_execution_policy" {
  name        = "ECS_Task_Execution_Policy"
  description = "Policy for ECS task execution"
  
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:RunTask",
        "ecs:StopTask",
        "ecs:DescribeTasks"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

# Define the IAM role for ECS task execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ECS_Task_Execution_Role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ecs-tasks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

# Attach the IAM policy to the IAM role
resource "aws_iam_policy_attachment" "ecs_task_execution_attachment" {
  name       = "ECS_Task_Execution_Policy_Attachment"
  roles      = [aws_iam_role.ecs_task_execution_role.name]
  policy_arn = aws_iam_policy.ecs_task_execution_policy.arn
}

resource "aws_ecs_service" "my_service" {
  name            = "my-service"
  cluster         = aws_ecs_cluster.foo.id
  task_definition = aws_ecs_task_definition.my_task_definition.arn
  desired_count   = 1
  launch_type = "FARGATE"

  network_configuration {
    subnets         = ["subnet-0897fdb1a8f47ee97"]
    security_groups = [aws_security_group.ecs_service_sg.id]
  }
}

resource "aws_security_group" "my_security_group" {
  name        = "my-security-group"
  description = "My security group description"
  vpc_id      = "vpc-0e536eba9e8efb4f3"

  // Inbound rules (allow incoming traffic)
  ingress {
    from_port   = 80 // Example port, adjust as needed
    to_port     = 80 // Example port, adjust as needed
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // Allow traffic from anywhere (example)
  }

  // Outbound rules (allow outgoing traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_service_sg" {
  name        = "ecs-service-sg"
  description = "Security group for ECS service"
  vpc_id      = "vpc-0e536eba9e8efb4f3"

  // Inbound rule (allow traffic from the load balancer)
  ingress {
    from_port         = 80 // Example port, adjust as needed
    to_port           = 80 // Example port, adjust as needed
    protocol          = "tcp"
    security_groups   = [aws_security_group.my_security_group.id] // Allow traffic from the ALB security group
  }

  // Outbound rules (allow outgoing traffic)
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
