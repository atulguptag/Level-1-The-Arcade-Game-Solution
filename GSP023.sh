gcloud storage cp -r gs://spls/gsp023/flex_and_vision/ .

cd flex_and_vision

export PROJECT_ID=$(gcloud config get-value project)

gcloud iam service-accounts create qwiklab \
  --display-name "My Qwiklab Service Account"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
--member serviceAccount:qwiklab@${PROJECT_ID}.iam.gserviceaccount.com \
--role roles/owner

gcloud iam service-accounts keys create ~/key.json \
--iam-account qwiklab@${PROJECT_ID}.iam.gserviceaccount.com

export GOOGLE_APPLICATION_CREDENTIALS="/home/${USER}/key.json"

virtualenv -p python3 env

source env/bin/activate

pip install -r requirements.txt

gcloud app create

export CLOUD_STORAGE_BUCKET=${PROJECT_ID}

gsutil mb gs://${PROJECT_ID}

python main.py
