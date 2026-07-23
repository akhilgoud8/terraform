# Run with: terraform test
# (from inside modules/rds/ — Terraform auto-discovers *.tftest.hcl in ./tests/)
#
# Uses mock_provider so these tests run completely offline — no AWS
# credentials or network access needed. Terraform generates fake but
# schema-valid values for every computed attribute.

mock_provider "aws" {}
mock_provider "random" {}

# ---------------------------------------------------------------------------
# SOURCE A: a top-level `variables` block. These values apply to every
# `run` block below unless a run block overrides them individually.
# This is the test-file equivalent of a shared tfvars file.
# ---------------------------------------------------------------------------
variables {
  identifier = "test-db"
  db_name    = "testdb"
  vpc_id     = "vpc-0123456789abcdef0"
  subnet_ids = ["subnet-aaaa1111", "subnet-bbbb2222"]
  password   = "SuperSecretPassw0rd!"
}

# ---------------------------------------------------------------------------
# Test 1: rely entirely on the shared `variables` block above (source A)
# plus the module's own variables.tf defaults (source B) for everything
# not explicitly set — confirms sane defaults produce a valid plan.
# ---------------------------------------------------------------------------
run "defaults_produce_valid_plan" {
  command = plan

  assert {
    condition     = aws_db_instance.this.engine == "postgres"
    error_message = "Expected default engine to be postgres"
  }

  assert {
    condition     = aws_db_instance.this.instance_class == "db.t3.micro"
    error_message = "Expected default instance_class to be db.t3.micro"
  }

  assert {
    condition     = aws_db_instance.this.multi_az == false
    error_message = "Expected multi_az to default to false"
  }
}

# ---------------------------------------------------------------------------
# Test 2: SOURCE C — a `variables` block scoped to this run only,
# overriding just instance_class and multi_az. Everything else still
# comes from the shared block above. This mirrors how -var on the CLI
# overrides a value that came from tfvars.
# ---------------------------------------------------------------------------
run "prod_sized_instance_overrides_defaults" {
  command = plan

  variables {
    instance_class = "db.r6g.large"
    multi_az       = true
    engine         = "postgres"
  }

  assert {
    condition     = aws_db_instance.this.instance_class == "db.r6g.large"
    error_message = "instance_class override did not take effect"
  }

  assert {
    condition     = aws_db_instance.this.multi_az == true
    error_message = "multi_az override did not take effect"
  }
}

# ---------------------------------------------------------------------------
# Test 3: confirm the auto-generated password path works when the caller
# passes an empty string instead of a real password (e.g. a CI job that
# intentionally omits TF_VAR_password to test the fallback behavior).
# ---------------------------------------------------------------------------
run "empty_password_triggers_random_generation" {
  command = plan

  variables {
    password = ""
  }

  assert {
    condition     = length(random_password.master) == 1
    error_message = "Expected a random_password resource to be created when password is empty"
  }
}

# ---------------------------------------------------------------------------
# Test 4: confirm the port defaults correctly per engine when var.port
# is left null — checks the lookup table in main.tf's locals.
# ---------------------------------------------------------------------------
run "mysql_engine_gets_mysql_default_port" {
  command = plan

  variables {
    engine = "mysql"
  }

  assert {
    condition     = aws_db_instance.this.port == 3306
    error_message = "Expected mysql engine to default to port 3306"
  }
}

run "postgres_engine_gets_postgres_default_port" {
  command = plan

  assert {
    condition     = aws_db_instance.this.port == 5432
    error_message = "Expected postgres engine to default to port 5432"
  }
}

# ---------------------------------------------------------------------------
# Test 5: validation failure path — parameters set without a matching
# parameter_group_family should fail plan with our custom precondition
# error message, not an opaque AWS API error.
# ---------------------------------------------------------------------------
run "custom_parameters_without_family_fails" {
  command = plan

  variables {
    parameters = {
      max_connections = "200"
    }
    # parameter_group_family intentionally omitted
  }

  expect_failures = [
    aws_db_parameter_group.this,
  ]
}

# ---------------------------------------------------------------------------
# Test 6: providing parameter_group_family alongside parameters succeeds.
# ---------------------------------------------------------------------------
run "custom_parameters_with_family_succeeds" {
  command = plan

  variables {
    parameters = {
      max_connections = "200"
    }
    parameter_group_family = "postgres15"
  }

  assert {
    condition     = length(aws_db_parameter_group.this) == 1
    error_message = "Expected a parameter group to be created"
  }
}
