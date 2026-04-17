---
inclusion: always
---

# AWS Documentation Reference

When writing or reviewing AWS infrastructure code (CloudFormation, CDK, Terraform, SAM),
always reference the official AWS documentation using the AWS Documentation MCP server.

## Rules

- Before writing any CloudFormation resource, look up its required and optional properties
  using `search_documentation` or `read_documentation` from the aws-docs MCP server.
- When unsure about a service's configuration options, search the docs first rather than guessing.
- Cite the documentation URL in code comments when using non-obvious properties or configurations.
- Use `read_sections` to pull specific sections when you only need part of a long docs page.
- Use `recommend` to discover related best practices pages after reading a primary doc.

## Example Workflow

1. User asks to create a Lambda function with an S3 trigger
2. Search: `search_documentation("S3 event notification Lambda trigger")`
3. Read the relevant page: `read_documentation("https://docs.aws.amazon.com/lambda/latest/dg/with-s3.html")`
4. Use the documented properties and patterns in the generated code
5. Add a comment in the template referencing the docs URL
