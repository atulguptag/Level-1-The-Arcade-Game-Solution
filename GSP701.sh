#Task 1 to 3
export PROJECT_ID=$(gcloud info --format="value(config.project)")

go version

git clone https://github.com/GoogleCloudPlatform/DIY-Tools.git

gcloud firestore import gs://$PROJECT_ID-firestore/prd-back

#No need to do "Task 4"
#Task 5. Test the application in your browser
export PROJECT_ID=$(gcloud info --format="value(config.project)")

export PREVIEW_URL=[REPLACE_WITH_WEB_PREVIEW_URL]

echo $PREVIEW_URL/fs/$PROJECT_ID/symbols/product/symbol

#Task 6. Deploy to App Engine
cd ~/DIY-Tools/gcp-data-drive/cmd/webserver

gcloud app deploy app.yaml --project $PROJECT_ID -q

export TARGET_URL=https://$(gcloud app describe --format="value(defaultHostname)")

curl $TARGET_URL/fs/$PROJECT_ID/symbols/product/symbol

curl $TARGET_URL/fs/$PROJECT_ID/symbols/product/symbol/008888166900

curl $TARGET_URL/bq/$PROJECT_ID/publicviews/ca_zip_codes

