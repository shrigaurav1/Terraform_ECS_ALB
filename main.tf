provider "aws" {
    region = "us-west-2"
}

#Application loadbalancer 

resource "aws_lb" "ecs_alb" {
  name               = "ecs-fargate-alb"
  internal           = false # Set to true for internal ALB
  load_balancer_type = "application"
  subnets            = ["subnet-0c5a82504f4edf254", "subnet-02dfac21a35f68e39"]
  security_groups    = ["sg-0699da602dfed0552"] # Attach ALB security group

  tags = {
    Name = "ecs-fargate-alb"
  }
}

# Create a Target Group for ECS Fargate with target_type = "ip"
resource "aws_lb_target_group" "ecs_fargate_tg" {
  name        = "ecs-fargate-tg"
  port        = 80 # Your application's port
  protocol    = "HTTP"
  vpc_id      = "vpc-02df15041ae6c516d"
  target_type = "ip" # Crucial for ECS Fargate

  health_check {
    path                = "/" # Your application's health check path
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "ecs-fargate-target-group"
  }
}

# Create an ALB Listener
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_fargate_tg.arn
  }
}

# Creating an TaskDefinition 

resource "aws_ecs_task_definition" "this" {
  family                   = "fargate-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"

task_role_arn      = "arn:aws:iam::977873000571:role/Ecstaskrole"
execution_role_arn = "arn:aws:iam::977873000571:role/Ecstaskrole"

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = "977873000571.dkr.ecr.us-west-2.amazonaws.com/nginx/images:latest"
      essential = true
      portMappings = [{
        containerPort = 80
        protocol      = "tcp"
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/fargate-task"
          awslogs-create-group  = "true"
          awslogs-region        = "us-west-2"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

 # enable_execute_command = true
}

# Creating ECS CLUSTER

resource "aws_ecs_cluster" "this" {
  name = "ECS_Cluster"
}

# CLOUDWATCH LOG GROUP

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/fargate-task"
  retention_in_days = 3
}

# ECS SERVICE

resource "aws_ecs_service" "this" {
  name            = "ECS_Service_NGINX"
  cluster         = aws_ecs_cluster.this.id
  
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  enable_execute_command = true

  network_configuration {
    subnets         = ["subnet-089f6b05f419311a7","subnet-011626f862159b2ec"]
    security_groups = ["sg-011cf48936c0bcdb0"]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_fargate_tg.arn
    container_name   = "app"
    container_port   = 80
  }

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
}

# AUTO SCALING (2 → 4 tasks)

resource "aws_appautoscaling_target" "ecs" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu_scale_up" {
  name               = "cpu-scale-up"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 70

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}