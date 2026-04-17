# Demo 3b: YAML IaC Best Practices with Kiro

## What This Shows
- Auto-linting hook: yamllint runs automatically when you save a YAML file
- Kiro fixes linting issues for you
- AWS Documentation MCP server provides real-time reference
- IaC development with best practices enforced by steering files

## Prerequisites
- yamllint installed: `pip install yamllint`
- Hook `yaml-lint-on-save` active (already created in `.kiro/hooks/`)
- AWS API MCP server configured (already in `.kiro/settings/mcp.json`)

## Demo A: Auto-Linting Hook

### 1. Create a YAML file with intentional issues
Create `demos/sample-iac/bad-template.yml` with these problems:
```yaml
AWSTemplateFormatVersion: 2010-09-09
Resources:
  MyBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: my-bucket
      Tags:
       - Key: Environment
         Value: prod
       - Key: Team
         Value:    "engineering"
      VersioningConfiguration:
          Status: Enabled
```
Issues: inconsistent indentation, extra spaces, missing Description field.

### 2. Save the file
The `yaml-lint-on-save` hook fires automatically. Kiro will:
1. Run `yamllint` on the file
2. See the linting errors
3. Fix them automatically
4. The file updates in your editor

### 3. Point out what happened
- The hook triggered on save — no manual action needed
- Kiro understood the YAML context (CloudFormation template)
- Fixes were applied while preserving the template's intent

## Demo B: AWS Documentation MCP Server

### 1. Ask Kiro about a CloudFormation resource
```
What are the required properties for an AWS::ECS::Service
CloudFormation resource? I want to deploy a Fargate service.
```

Kiro will use the AWS API MCP server or web search to pull the latest
documentation and give you accurate, current property definitions.

### 2. Ask Kiro to write IaC from a requirement
```
Write a CloudFormation template that creates:
- A VPC with 2 public and 2 private subnets
- An ECS Fargate cluster
- A task definition running nginx
- An ALB in front of the service

Follow the coding standards in our steering files (all resources tagged,
no hardcoded values, Description field required).

Save it to demos/sample-iac/ecs-fargate.yml
```

### 3. Save the generated file
The yamllint hook fires and validates the output. If Kiro's generated
YAML has any formatting issues, the hook catches and fixes them.

## Demo C: Steering Files in Action

### 1. Show the coding standards
Open `.kiro/steering/coding-standards.md` and point out the YAML section:
- 2-space indentation
- Quote ambiguous strings
- Document separator `---` at top
- CloudFormation: always include Description

### 2. Ask Kiro to write YAML that violates standards
```
Write a CloudFormation template for an S3 bucket. Use tabs for indentation
and don't include a Description field.
```

Kiro will refuse or auto-correct because the steering file is auto-included
in every interaction. The standards are enforced by default.

## What to Point Out During Demo
- Hooks are event-driven — no CI pipeline needed for local linting
- The yamllint hook replaces the manual `yamllint` step in a developer's workflow
- Steering files enforce standards without developers having to remember them
- The AWS MCP server gives Kiro access to real AWS documentation
- This is "shift left" — issues caught at save time, not at PR time
