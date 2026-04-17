# Demo 3c: Data Pipeline from Scratch

## What This Shows
- Ask Kiro to build a complete data pipeline from a business requirement
- Kiro writes the IaC (CloudFormation/CDK), the Lambda code, and the glue
- Deploy it to your AWS account and see it in the console
- End-to-end: requirement → code → deploy → verify in console

## Steps

### 1. Give Kiro the requirement

Paste this into Kiro chat:

```
Build me a serverless data pipeline that:

1. Has an S3 bucket for incoming CSV files
2. An S3 event notification triggers a Lambda function when a CSV is uploaded
3. The Lambda reads the CSV, transforms it (adds a processed_at timestamp
   column), and writes it as Parquet to a second S3 bucket
4. A Glue table is created on top of the output bucket so I can query
   it from Athena

Use CloudFormation. Deploy it to my AWS account in us-east-1.
Name the stack "demo-data-pipeline".

Follow our coding standards:
- All resources tagged with Environment=demo, Team=platform, Service=data-pipeline
- No hardcoded account IDs
- IAM least privilege
- Include a Description field in the template

Save the template to demos/sample-iac/data-pipeline.yml
Save the Lambda code to demos/sample-iac/lambda/transform.py

After saving, deploy it using the AWS CLI.
```

### 2. Watch Kiro work
Kiro will:
1. Write the CloudFormation template (S3 buckets, Lambda, IAM role, Glue table)
2. Write the Lambda function (Python, reads CSV, writes Parquet)
3. Save both files
4. The yamllint hook fires on the YAML file and validates it
5. Package and deploy via `aws cloudformation deploy`

### 3. Verify in AWS Console
- **CloudFormation**: See the `demo-data-pipeline` stack
- **S3**: Two buckets created (input + output)
- **Lambda**: The transform function
- **Glue**: The table definition pointing at the output bucket

### 4. Test the pipeline
```
Upload a test CSV to the input bucket and verify the pipeline works.
Create a small test CSV with 5 rows, upload it, wait for the Lambda
to process it, then query the output from Athena.
```

Kiro will:
1. Create a test CSV
2. Upload it to the input bucket via `aws s3 cp`
3. Wait for Lambda to process
4. Query the output via Athena to verify the Parquet data

## Alternative: CDK Version

If the audience prefers CDK:
```
Same requirements as above, but use AWS CDK (TypeScript) instead of
CloudFormation. Create the CDK app in demos/sample-iac/cdk-pipeline/
and deploy it.
```

## Cleanup
```bash
aws cloudformation delete-stack --stack-name demo-data-pipeline --region us-east-1
```

## What to Point Out During Demo
- Kiro wrote the full stack: IaC + application code + deployment
- The yamllint hook caught any YAML issues automatically
- Steering files enforced tagging, least privilege, no hardcoded values
- The pipeline is real — you can see it in the AWS console
- The test proves it works end-to-end: CSV in → Parquet out → queryable in Athena
- Total time: ~10 minutes from requirement to working pipeline in AWS
- This is the "from zero to production" story
