clean:		## delete pycache, build files
	@sudo rm -rf deploy  
	@sudo rm -rf layer 
	@sudo rm -rf __pycache__

## create Docker image with requirements
docker-build:	
	sudo cd bin; sudo unzip -u ../chromium.zip 	
	sudo docker-compose build
	sudo rm -f bin/chromium

## run "src.lambda_function.lambda_handler" with docker-compose
## mapping "./tmp" and "./src" folders. 
## "event.json" file is loaded and provided to lambda function as event parameter  
lambda-run:	sudo docker-build		
	sudo docker-compose run lambda src.lambda_function.lambda_handler 

## prepares layer.zip archive for AWS Lambda Layer deploy 
lambda-layer-build: clean 
	sudo rm -f layer.zip
	sudo mkdir layer layer/python
	sudo cp -r bin layer/.
	sudo cd layer/bin; sudo unzip -u ../../chromium.zip 
	sudo pip3 install -r requirements.txt -t layer/python
	sudo cd layer; sudo zip -9qr layer.zip .
	sudo cp layer/layer.zip .
	sudo rm -rf layer

## prepares deploy.zip archive for AWS Lambda Function deploy 
lambda-function-build: clean 
	sudo rm -f deploy.zip
	sudo mkdir deploy 
	sudo cp -r src deploy/.
	sudo cd deploy; sudo  zip -9qr deploy.zip .
	sudo cp deploy/deploy.zip .
	sudo rm -rf deploy

## create CloudFormation stack with lambda function and role.
## usage:	make BUCKET=your_bucket_name create-stack 
create-stack: 
	sudo aws s3 cp layer.zip s3://${BUCKET}/src/SeleniumChromiumLayer.zip
	sudo aws s3 cp deploy.zip s3://${BUCKET}/src/ScreenshotFunction.zip
	sudo aws cloudformation create-stack --stack-name LambdaScreenshot --template-body file://cloud.yaml --parameters ParameterKey=BucketName,ParameterValue=${BUCKET} --capabilities CAPABILITY_IAM