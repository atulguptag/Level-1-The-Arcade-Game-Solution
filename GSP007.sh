

#Step - 1
gcloud compute instances create www1 \
    --zone=us-east4-a \
    --tags=network-lb-tag \
    --machine-type=e2-small \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
      apt-get update
      apt-get install apache2 -y
      service apache2 restart
      echo "
<h3>Web Server: www1</h3>" | tee /var/www/html/index.html'

gcloud compute instances create www2 \
    --zone=us-east4-a \
    --tags=network-lb-tag \
    --machine-type=e2-small \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
      apt-get update
      apt-get install apache2 -y
      service apache2 restart
      echo "
<h3>Web Server: www2</h3>" | tee /var/www/html/index.html'
  
gcloud compute instances create www3 \
    --zone=us-east4-a  \
    --tags=network-lb-tag \
    --machine-type=e2-small \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
      apt-get update
      apt-get install apache2 -y
      service apache2 restart
      echo "
<h3>Web Server: www3</h3>" | tee /var/www/html/index.html'

gcloud compute firewall-rules create www-firewall-network-lb \
    --target-tags network-lb-tag --allow tcp:80

gcloud compute instances list

gcloud compute addresses create network-lb-ip-1 \
  --region us-east4

gcloud compute http-health-checks create basic-check

gcloud compute target-pools create www-pool \
  --region us-east4 --http-health-check basic-check

gcloud compute target-pools add-instances www-pool \
    --instances www1,www2,www3
gcloud compute forwarding-rules create www-rule \
    --region  us-east4 \
    --ports 80 \
    --address network-lb-ip-1 \
    --target-pool www-pool
gcloud compute forwarding-rules describe www-rule --region us-east4
IPADDRESS=$(gcloud compute forwarding-rules describe www-rule --region us-east4 --format="json" | jq -r .IPAddress)
echo $IPADDRESS
while true; do curl -m1 $IPADDRESS; done

#After the above command, Press "Ctrl + C"

#Step - 2
gcloud compute instance-templates create lb-backend-template \
   --region=us-east4 \
   --network=default \
   --subnet=default \
   --tags=allow-health-check \
   --machine-type=e2-medium \
   --image-family=debian-11 \
   --image-project=debian-cloud \
   --metadata=startup-script='#!/bin/bash
     apt-get update
     apt-get install apache2 -y
     a2ensite default-ssl
     a2enmod ssl
     vm_hostname="$(curl -H "Metadata-Flavor:Google" \
     http://169.254.169.254/computeMetadata/v1/instance/name)"
     echo "Page served from: $vm_hostname" | \
     tee /var/www/html/index.html
     systemctl restart apache2'
gcloud compute instance-groups managed create lb-backend-group \
   --template=lb-backend-template --size=2 --zone=us-east4-a 
gcloud compute firewall-rules create fw-allow-health-check \
  --network=default \
  --action=allow \
  --direction=ingress \
  --source-ranges=130.211.0.0/22,35.191.0.0/16 \
  --target-tags=allow-health-check \
  --rules=tcp:80
gcloud compute addresses create lb-ipv4-1 \
  --ip-version=IPV4 \
  --global
gcloud compute addresses describe lb-ipv4-1 \
  --format="get(address)" \
  --global
gcloud compute health-checks create http http-basic-check \
  --port 80
gcloud compute backend-services create web-backend-service \
  --protocol=HTTP \
  --port-name=http \
  --health-checks=http-basic-check \
  --global
gcloud compute backend-services add-backend web-backend-service \
  --instance-group=lb-backend-group \
  --instance-group-zone=us-east4-a \
  --global
gcloud compute url-maps create web-map-http \
    --default-service web-backend-service
gcloud compute target-http-proxies create http-lb-proxy \
    --url-map web-map-http
gcloud compute forwarding-rules create http-content-rule \
    --address=lb-ipv4-1\
    --global \
    --target-http-proxy=http-lb-proxy \
    --ports=80