# Lab Name - VPC Networking Fundamentals
# Lab Link - https://www.cloudskillsboost.google/focuses/1229?parent=catalog

# Paste the below commands👇🏻 in the Cloud Shell Terminal

gcloud compute networks create mynetwork 
    --subnet-mode=auto

gcloud compute instances create mynet-us-vm 
    --region=us-west3
    --zone=us-west3-c
    --machine-type=e2-micro

gcloud compute instances create mynet-second-vm 
    --region=us-west4
    --zone=us-west4-a
    --machine-type=e2-micro
