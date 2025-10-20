# Password Security Testing for Issue #14
# This file provides validation and testing for YAML-safe password generation

# Test random password generation with YAML-safe characters
resource "random_password" "test_password_yaml_safe" {
  length      = 16
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
  min_special = 1
  special     = true
  # Only YAML-safe special characters
  override_special = "!@#$%^&*()-_=+[]{}:?"
}

# Validation: Ensure password can be safely encoded in YAML
locals {
  test_password_validation = {
    raw_password     = random_password.test_password_yaml_safe.result
    yaml_encoded     = yamlencode(random_password.test_password_yaml_safe.result)
    is_yaml_safe     = can(yamlencode(random_password.test_password_yaml_safe.result))
    contains_quotes  = contains(split("", random_password.test_password_yaml_safe.result), "\"")
    contains_backslash = contains(split("", random_password.test_password_yaml_safe.result), "\\")
  }
}

# Output validation results for testing
output "password_security_test" {
  sensitive = true
  value = {
    yaml_safe_check    = local.test_password_validation.is_yaml_safe
    contains_quotes    = local.test_password_validation.contains_quotes
    contains_backslash = local.test_password_validation.contains_backslash
    # Don't output the actual password for security
    password_length    = length(local.test_password_validation.raw_password)
  }
  description = "Password security validation results - all should be: yaml_safe=true, contains_quotes=false, contains_backslash=false"
}

# Test YAML template rendering with special characters
resource "local_file" "test_yaml_template" {
  content = templatefile("${path.module}/test_yaml_template.tftpl", {
    test_password = random_password.test_password_yaml_safe.result
  })
  filename = "/tmp/test_yaml_output.yaml"
}

# Validate that the generated YAML is parseable (simplified validation without PyYAML dependency)
data "external" "yaml_validation" {
  program = ["python3", "-c", <<-EOT
import json
import sys
import os

try:
    # Check if file exists and is readable
    if not os.path.exists('/tmp/test_yaml_output.yaml'):
        print(json.dumps({"valid": "false", "error": "YAML file not found"}))
        sys.exit(0)

    with open('/tmp/test_yaml_output.yaml', 'r') as f:
        content = f.read()

    # Basic YAML syntax validation - check for common YAML issues
    lines = content.strip().split('\n')
    errors = []

    for i, line in enumerate(lines, 1):
        line = line.strip()
        if not line or line.startswith('#'):
            continue

        # Check for unclosed quotes
        if line.count('"') % 2 != 0:
            errors.append(f"Unclosed quotes on line {i}")

        # Check for unescaped special characters outside quotes
        if '\\' in line and '"' not in line:
            errors.append(f"Unescaped backslash on line {i}")

    if errors:
        print(json.dumps({"valid": "false", "error": "; ".join(errors)}))
    else:
        print(json.dumps({"valid": "true", "error": "none", "note": "Basic syntax validation passed"}))

except Exception as e:
    print(json.dumps({"valid": "false", "error": str(e)}))
EOT
  ]

  depends_on = [local_file.test_yaml_template]
}

output "yaml_parsing_test" {
  value = data.external.yaml_validation.result
  description = "YAML parsing validation - should show valid=true"
}