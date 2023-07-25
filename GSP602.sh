# Lab Name - HTTP Google Cloud Functions in Go
# Lab Link - https://www.cloudskillsboost.google/focuses/5171?parent=catalog



gcloud services enable cloudfunctions.googleapis.com

curl -LO https://github.com/GoogleCloudPlatform/golang-samples/archive/main.zip

unzip main.zip

cd golang-samples-main/functions/codelabs/gopher

gcloud functions deploy HelloWorld --runtime go111 --trigger-http

gcloud functions deploy Gopher --runtime go111 --trigger-http
