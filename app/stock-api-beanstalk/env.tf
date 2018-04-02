provider "aws" {
  access_key = "access"
  secret_key = "secret"
  region     = "eu-west-1"
}

resource "aws_iam_instance_profile" "beanstalk_service" {
    name = "beanstalk-service-user"
    roles = ["${aws_iam_role.beanstalk_service.name}"]
}

resource "aws_iam_instance_profile" "beanstalk_ec2" {
    name = "beanstalk-ec2-user"
    roles = ["${aws_iam_role.beanstalk_ec2.name}"]
}

resource "aws_iam_role" "beanstalk_service" {
    name = "beanstalk-service-role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "elasticbeanstalk.amazonaws.com"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "elasticbeanstalk"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role" "beanstalk_ec2" {
    name = "beanstalk-ec2-role"
    assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "beanstalk_service" {
    name = "elastic-beanstalk-service"
    roles = ["${aws_iam_role.beanstalk_service.id}"]
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkService"
}

resource "aws_iam_policy_attachment" "beanstalk_service_health" {
    name = "elastic-beanstalk-service-health"
    roles = ["${aws_iam_role.beanstalk_service.id}"]
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}


resource "aws_iam_policy_attachment" "beanstalk_ec2_web" {
    name = "elastic-beanstalk-ec2-web"
    roles = ["${aws_iam_role.beanstalk_ec2.id}"]
    policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}


  resource "aws_elastic_beanstalk_application" "stock-api" {
    name        = "stock-api"
    description = "stock-api"
  }

  resource "aws_elastic_beanstalk_environment" "stock-api-dev" {
    name                = "stock-api-dev"
    application         = "stock-api"
    solution_stack_name = "64bit Amazon Linux 2017.03 v2.4.4 running PHP 7.0"
    tier                = "WebServer"
    setting {
      namespace = "aws:autoscaling:launchconfiguration"
      name  = "InstanceType"
      value = "t2.small"
    }

    setting {
      namespace = "aws:autoscaling:launchconfiguration"
      name      = "IamInstanceProfile"
      value     = "aws-elasticbeanstalk-ec2-role"
    }
    setting {
      namespace = "aws:autoscaling:asg"
      name      = "MinSize"
      value = "1"
    }

    setting {
      namespace = "aws:autoscaling:asg"
      name = "Availability Zones"
      value = "Any 2"
    }

    setting {
      namespace = "aws:autoscaling:asg"
      name      = "MaxSize"
      value = "2"
    }

    setting {
      namespace = "aws:ec2:vpc"
      name      = "VPCId"
      value     = "${var.dev_vpc_id}"
    }

    setting {
      namespace = "aws:ec2:vpc"
      name = "ELBScheme"
      value = "external"
    }

    setting {
      namespace = "aws:ec2:vpc"
      name = "AssociatePublicIpAddress"
      value = "true"
    }

    setting {
      namespace = "aws:autoscaling:launchconfiguration"
      name = "EC2KeyName"
      value = "beanstalk"
    }

    setting {
      namespace = "aws:elasticbeanstalk:application:environment"
      name = "ENVIRONMENT"
      value = "dev"
    }

    setting {
      namespace = "aws:elasticbeanstalk:healthreporting:system"
      name = "SystemType"
      value = "enhanced"
    }

    setting {
      namespace = "aws:autoscaling:updatepolicy:rollingupdate"
      name = "RollingUpdateEnabled"
      value = "true"
    }

    setting {
      namespace = "aws:autoscaling:updatepolicy:rollingupdate"
      name = "RollingUpdateType"
      value = "Health"
    }

    setting {
      namespace = "aws:autoscaling:launchconfiguration"
      name = "RootVolumeType"
      value = "gp2"
    }

    setting {
      namespace = "aws:autoscaling:launchconfiguration"
      name = "RootVolumeSize"
      value = "100"
    }
    setting {
      namespace = "aws:ec2:vpc"
      name      = "Subnets"
      value     = "${var.dev_subnets}"
    }
    setting {
      namespace = "aws:ec2:vpc"
      name      = "ELBSubnets"
      value     = "${var.dev_subnets}"
    }
    setting {
      namespace = "aws:elasticbeanstalk:environment"
      name = "ServiceRole"
      value = "aws-elasticbeanstalk-service-role"
    }
    setting {
      namespace = "aws:elasticbeanstalk:cloudwatch:logs"
      name = "StreamLogs"
      value = "true"
    }
    setting {
      namespace = "aws:elasticbeanstalk:cloudwatch:logs"
      name = "DeleteOnTerminate"
      value = "true"
    }
    setting {
      namespace = "aws:elasticbeanstalk:cloudwatch:logs"
      name = "RetentionInDays"
      value = "90"
    }
    setting {
      namespace = "aws:elasticbeanstalk:sns:topics"
      name = "Notification Protocol"
      value = "email"
    }
    setting {
      namespace = "aws:elasticbeanstalk:sns:topics"
      name = "Notification Endpoint"
      value = "ops@eftsoftware.com"
    }
    setting {
      namespace = "aws:elasticbeanstalk:managedactions"
      name = "ManagedActionsEnabled"
      value = "true"
    }
    setting {
      namespace = "aws:elasticbeanstalk:managedactions"
      name = "PreferredStartTime"
      value = "Sat:04:00"
    }
    setting {
      namespace = "aws:elasticbeanstalk:application:environment"
      name = "SUMOLOGIC_ACCESS_ID"
      value = "suKbBWKBtMKV2O"
    }
    setting {
      namespace = "aws:elasticbeanstalk:application:environment"
      name = "SUMOLOGIC_ACCESS_KEY"
      value = "XpraYhrnzAdUwNaX1lm6WovZSpySzaC0Fzktwvl3SDsphPpb9PaAL9tIYaC79DcF"
    }

    setting {
      namespace = "aws:elasticbeanstalk:application:environment"
      name = "SUMOLOGIC_SOURCE_CATEGORY"
      value = "stock-api-dev"
    }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "APP_ENV"
                          value = "local"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "APP_DEBUG"
                          value = "false"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "APP_KEY_ALT"
                          value = "I6V9SNheOsCSsw7DiFVN0tMThnTjpX4n"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "JWT_SECRET"
                          value = "9oyf2NiJgvOgvaRi"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "APP_KEY"
                          value = "I6V9SNheOsCSsw7DiFVN0tMThnTjpX4n"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "APP_LOCALE"
                          value = "en"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "APP_FALLBACK_LOCALE"
                          value = "en"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "EPRO_ID"
                          value = "1"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "PAYDOH_ID"
                          value = "1"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "DB_HOST"
                          value = "localhost"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "DB_DATABASE"
                          value = "homestead"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "DB_USERNAME"
                          value = "homestead"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "DB_PASSWORD"
                          value = "secret"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "OLD_DB_HOST"
                          value = "localhost"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "OLD_DB_DATABASE"
                          value = "old_stock"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "OLD_DB_USERNAME"
                          value = "homestead"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "OLD_DB_PASSWORD"
                          value = "secret"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "REPORTING_HOST"
                          value = "10.0.2.2:27017"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "REPORTING_DATABASE"
                          value = "reporting"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "REPORTING_USERNAME"
                          value = ""
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "REPORTING_PASSWORD"
                          value = ""
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "REPORTING_REPLICASET"
                          value = ""
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "stock_API_URL"
                          value = "http://api.stock/api/v3/"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "stock_ADMIN_KEY"
                          value = "Zuu3mUjUeznXKy"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "stock_REPORTING_URL"
                          value = "http://reporting.stock/api/v3/bumin-hamam-07/"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "stock_CHECKOUT_URL"
                          value = "http://payment.stock/"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "stock_IPAYNET_CHECKOUT_URL"
                          value = "http://payment.stock/"
                        }


    setting {
      namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
      name = "UpdateLevel"
      value = "minor"
    }
    provisioner "file" {
      source      = "install_newrelic_agent.sh"
      destination = "/tmp/install_newrelic_agent.sh"
    }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_newrelic_agent.sh",
      "sh /tmp/install_newrelic_agent.sh",
      ]
    }
    tags {
      Team = "stock-api"
      Environment = "DEV"
    }
  }

  resource "aws_elastic_beanstalk_environment" "stock-api-test" {
    name                = "stock-api-test"
    application         = "stock-api"
    solution_stack_name = "64bit Amazon Linux 2017.03 v2.4.4 running PHP 7.0"
    tier                = "WebServer"
    setting {
      namespace = "aws:autoscaling:launchconfiguration"
      name  = "InstanceType"
      value = "t2.small"
    }

    setting {
      namespace = "aws:autoscaling:launchconfiguration"
      name      = "IamInstanceProfile"
      value     = "aws-elasticbeanstalk-ec2-role"
    }
    setting {
      namespace = "aws:autoscaling:asg"
      name      = "MinSize"
      value = "1"
    }

    setting {
      namespace = "aws:autoscaling:asg"
      name = "Availability Zones"
      value = "Any 2"
    }

    setting {
      namespace = "aws:autoscaling:asg"
      name      = "MaxSize"
      value = "2"
    }

    setting {
      namespace = "aws:ec2:vpc"
      name      = "VPCId"
      value     = "${var.test_vpc_id}"
    }

    setting {
      namespace = "aws:ec2:vpc"
      name = "ELBScheme"
      value = "external"
    }

    setting {
      namespace = "aws:ec2:vpc"
      name = "AssociatePublicIpAddress"
      value = "true"
    }

    setting {
      namespace = "aws:autoscaling:launchconfiguration"
      name = "EC2KeyName"
      value = "beanstalk"
    }

    setting {
      namespace = "aws:elasticbeanstalk:application:environment"
      name = "ENVIRONMENT"
      value = "test"
    }

    setting {
      namespace = "aws:elasticbeanstalk:healthreporting:system"
      name = "SystemType"
      value = "enhanced"
    }

    setting {
      namespace = "aws:autoscaling:updatepolicy:rollingupdate"
      name = "RollingUpdateEnabled"
      value = "true"
    }

    setting {
      namespace = "aws:autoscaling:updatepolicy:rollingupdate"
      name = "RollingUpdateType"
      value = "Health"
    }

    setting {
      namespace = "aws:autoscaling:launchconfiguration"
      name = "RootVolumeType"
      value = "gp2"
    }

    setting {
      namespace = "aws:autoscaling:launchconfiguration"
      name = "RootVolumeSize"
      value = "100"
    }
    setting {
      namespace = "aws:ec2:vpc"
      name      = "Subnets"
      value     = "${var.test_subnets}"
    }
    setting {
      namespace = "aws:ec2:vpc"
      name      = "ELBSubnets"
      value     = "${var.test_subnets}"
    }
    setting {
      namespace = "aws:elasticbeanstalk:environment"
      name = "ServiceRole"
      value = "aws-elasticbeanstalk-service-role"
    }
    setting {
      namespace = "aws:elasticbeanstalk:cloudwatch:logs"
      name = "StreamLogs"
      value = "true"
    }
    setting {
      namespace = "aws:elasticbeanstalk:cloudwatch:logs"
      name = "DeleteOnTerminate"
      value = "true"
    }
    setting {
      namespace = "aws:elasticbeanstalk:cloudwatch:logs"
      name = "RetentionInDays"
      value = "90"
    }
    setting {
      namespace = "aws:elasticbeanstalk:sns:topics"
      name = "Notification Protocol"
      value = "email"
    }
    setting {
      namespace = "aws:elasticbeanstalk:sns:topics"
      name = "Notification Endpoint"
      value = "ops@eftsoftware.com"
    }
    setting {
      namespace = "aws:elasticbeanstalk:managedactions"
      name = "ManagedActionsEnabled"
      value = "true"
    }
    setting {
      namespace = "aws:elasticbeanstalk:managedactions"
      name = "PreferredStartTime"
      value = "Sat:04:00"
    }
    setting {
      namespace = "aws:elasticbeanstalk:application:environment"
      name = "SUMOLOGIC_ACCESS_ID"
      value = "suKbBWKBtMKV2O"
    }
    setting {
      namespace = "aws:elasticbeanstalk:application:environment"
      name = "SUMOLOGIC_ACCESS_KEY"
      value = "XpraYhrnzAdUwNaX1lm6WovZSpySzaC0Fzktwvl3SDsphPpb9PaAL9tIYaC79DcF"
    }

    setting {
      namespace = "aws:elasticbeanstalk:application:environment"
      name = "SUMOLOGIC_SOURCE_CATEGORY"
      value = "stock-api-test"
    }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "APP_ENV"
                          value = "local"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "APP_DEBUG"
                          value = "false"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "APP_KEY_ALT"
                          value = "I6V9SNheOsCSsw7DiFVN0tMThnTjpX4n"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "JWT_SECRET"
                          value = "9oyf2NiJgvOgvaRi"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "APP_KEY"
                          value = "I6V9SNheOsCSsw7DiFVN0tMThnTjpX4n"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "APP_LOCALE"
                          value = "en"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "APP_FALLBACK_LOCALE"
                          value = "en"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "EPRO_ID"
                          value = "1"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "PAYDOH_ID"
                          value = "1"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "DB_HOST"
                          value = "localhost"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "DB_DATABASE"
                          value = "homestead"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "DB_USERNAME"
                          value = "homestead"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "DB_PASSWORD"
                          value = "secret"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "OLD_DB_HOST"
                          value = "localhost"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "OLD_DB_DATABASE"
                          value = "old_stock"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "OLD_DB_USERNAME"
                          value = "homestead"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "OLD_DB_PASSWORD"
                          value = "secret"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "REPORTING_HOST"
                          value = "10.0.2.2:27017"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "REPORTING_DATABASE"
                          value = "reporting"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "REPORTING_USERNAME"
                          value = ""
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "REPORTING_PASSWORD"
                          value = ""
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "REPORTING_REPLICASET"
                          value = ""
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "stock_API_URL"
                          value = "http://api.stock/api/v3/"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "stock_ADMIN_KEY"
                          value = "Zuu3mUjUeznXKy"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "stock_REPORTING_URL"
                          value = "http://reporting.stock/api/v3/bumin-hamam-07/"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "stock_CHECKOUT_URL"
                          value = "http://payment.stock/"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "stock_IPAYNET_CHECKOUT_URL"
                          value = "http://payment.stock/"
                        }

    setting {
      namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
      name = "UpdateLevel"
      value = "minor"
    }
    provisioner "file" {
      source      = "install_newrelic_agent.sh"
      destination = "/tmp/install_newrelic_agent.sh"
    }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_newrelic_agent.sh",
      "sh /tmp/install_newrelic_agent.sh",
      ]
    }
    tags {
      Team = "stock-api"
      Environment = "TEST"
    }
  }

  resource "aws_elastic_beanstalk_environment" "stock-api-prod" {
    name                = "stock-api-prod"
    application         = "stock-api"
    solution_stack_name = "64bit Amazon Linux 2017.03 v2.4.4 running PHP 7.0"
    tier                = "WebServer"
    setting {
      namespace = "aws:autoscaling:launchconfiguration"
      name  = "InstanceType"
      value = "t2.small"
    }

    setting {
      namespace = "aws:autoscaling:launchconfiguration"
      name      = "IamInstanceProfile"
      value     = "aws-elasticbeanstalk-ec2-role"
    }
    setting {
      namespace = "aws:autoscaling:asg"
      name      = "MinSize"
      value = "1"
    }

    setting {
      namespace = "aws:autoscaling:asg"
      name = "Availability Zones"
      value = "Any 2"
    }

    setting {
      namespace = "aws:autoscaling:asg"
      name      = "MaxSize"
      value = "2"
    }

    setting {
      namespace = "aws:ec2:vpc"
      name      = "VPCId"
      value     = "${var.prod_vpc_id}"
    }

    setting {
      namespace = "aws:ec2:vpc"
      name = "ELBScheme"
      value = "external"
    }

    setting {
      namespace = "aws:ec2:vpc"
      name = "AssociatePublicIpAddress"
      value = "true"
    }

    setting {
      namespace = "aws:autoscaling:launchconfiguration"
      name = "EC2KeyName"
      value = "beanstalk"
    }

    setting {
      namespace = "aws:elasticbeanstalk:application:environment"
      name = "ENVIRONMENT"
      value = "prod"
    }

    setting {
      namespace = "aws:elasticbeanstalk:healthreporting:system"
      name = "SystemType"
      value = "enhanced"
    }

    setting {
      namespace = "aws:autoscaling:updatepolicy:rollingupdate"
      name = "RollingUpdateEnabled"
      value = "true"
    }

    setting {
      namespace = "aws:autoscaling:updatepolicy:rollingupdate"
      name = "RollingUpdateType"
      value = "Health"
    }

    setting {
      namespace = "aws:autoscaling:launchconfiguration"
      name = "RootVolumeType"
      value = "gp2"
    }

    setting {
      namespace = "aws:autoscaling:launchconfiguration"
      name = "RootVolumeSize"
      value = "100"
    }
    setting {
      namespace = "aws:ec2:vpc"
      name      = "Subnets"
      value     = "${var.prod_subnets}"
    }
    setting {
      namespace = "aws:ec2:vpc"
      name      = "ELBSubnets"
      value     = "${var.prod_subnets}"
    }
    setting {
      namespace = "aws:elasticbeanstalk:environment"
      name = "ServiceRole"
      value = "aws-elasticbeanstalk-service-role"
    }
    setting {
      namespace = "aws:elasticbeanstalk:cloudwatch:logs"
      name = "StreamLogs"
      value = "true"
    }
    setting {
      namespace = "aws:elasticbeanstalk:cloudwatch:logs"
      name = "DeleteOnTerminate"
      value = "true"
    }
    setting {
      namespace = "aws:elasticbeanstalk:cloudwatch:logs"
      name = "RetentionInDays"
      value = "90"
    }
    setting {
      namespace = "aws:elasticbeanstalk:sns:topics"
      name = "Notification Protocol"
      value = "email"
    }
    setting {
      namespace = "aws:elasticbeanstalk:sns:topics"
      name = "Notification Endpoint"
      value = "ops@eftsoftware.com"
    }
    setting {
      namespace = "aws:elasticbeanstalk:managedactions"
      name = "ManagedActionsEnabled"
      value = "true"
    }
    setting {
      namespace = "aws:elasticbeanstalk:managedactions"
      name = "PreferredStartTime"
      value = "Sat:04:00"
    }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "APP_ENV"
                          value = "local"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "APP_DEBUG"
                          value = "false"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "APP_KEY_ALT"
                          value = "I6V9SNheOsCSsw7DiFVN0tMThnTjpX4n"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "JWT_SECRET"
                          value = "9oyf2NiJgvOgvaRi"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "APP_KEY"
                          value = "I6V9SNheOsCSsw7DiFVN0tMThnTjpX4n"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "APP_LOCALE"
                          value = "en"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "APP_FALLBACK_LOCALE"
                          value = "en"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "EPRO_ID"
                          value = "1"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "PAYDOH_ID"
                          value = "1"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "DB_HOST"
                          value = "localhost"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "DB_DATABASE"
                          value = "homestead"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "DB_USERNAME"
                          value = "homestead"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "DB_PASSWORD"
                          value = "secret"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "OLD_DB_HOST"
                          value = "localhost"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "OLD_DB_DATABASE"
                          value = "old_stock"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "OLD_DB_USERNAME"
                          value = "homestead"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "OLD_DB_PASSWORD"
                          value = "secret"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "REPORTING_HOST"
                          value = "10.0.2.2:27017"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "REPORTING_DATABASE"
                          value = "reporting"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "REPORTING_USERNAME"
                          value = ""
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "REPORTING_PASSWORD"
                          value = ""
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "REPORTING_REPLICASET"
                          value = ""
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "stock_API_URL"
                          value = "http://api.stock/api/v3/"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "stock_ADMIN_KEY"
                          value = "Zuu3mUjUeznXKy"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "stock_REPORTING_URL"
                          value = "http://reporting.stock/api/v3/bumin-hamam-07/"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "stock_CHECKOUT_URL"
                          value = "http://payment.stock/"
                        }
    setting {
                          namespace = "aws:elasticbeanstalk:application:environment"
                          name = "stock_IPAYNET_CHECKOUT_URL"
                          value = "http://payment.stock/"
                        }

    setting {
      namespace = "aws:elasticbeanstalk:application:environment"
      name = "SUMOLOGIC_ACCESS_KEY"
      value = "XpraYhrnzAdUwNaX1lm6WovZSpySzaC0Fzktwvl3SDsphPpb9PaAL9tIYaC79DcF"
    }
    setting {
      namespace = "aws:elasticbeanstalk:application:environment"
      name = "SUMOLOGIC_SOURCE_CATEGORY"
      value = "stock-api-prod"
    }
    setting {
      namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
      name = "UpdateLevel"
      value = "minor"
    }
    provisioner "file" {
      source      = "install_newrelic_agent.sh"
      destination = "/tmp/install_newrelic_agent.sh"
    }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_newrelic_agent.sh",
      "sh /tmp/install_newrelic_agent.sh",
      ]
    }
    tags {
      Team = "stock-api"
      Environment = "PROD"
    }
  }
