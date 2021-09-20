aws s3 cp layer.zip s3://selinium-test-bucket/src/SeleniumChromiumLayer.zip 
aws s3 cp deploy.zip s3://selinium-test-bucket/src/ScreenshotFunction.zip
aws cloudformation create-stack --stack-name LambdaScreenshot --template-body file://cloud.yaml --parameters ParameterKey=BucketName,ParameterValue=selinium-test-bucket --capabilities CAPABILITY_IAM --region eu-west-1