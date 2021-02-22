# Create a loadbalancer

gcloud compute addresses create --global myservice-ip

gcloud compute backend-services create --global myservice-backend

gcloud compute url-maps create myservice-urlmap --default-service=myservice-backend

gcloud beta compute ssl-certificates create myservice-cert \
 --domains=gcp-eng.com

gcloud compute target-https-proxies create myservice-https \
 --ssl-certificates=myservice-cert \
 --url-map=myservice-urlmap

gcloud compute forwarding-rules create --global myservice-lb \
 --target-https-proxy=myservice-https \
 --address=myservice-ip \
 --ports=443

# CloudBuild

gcloud builds submit --tag gcr.io/mc-mutilcr-spanner/helloworld

# Deploy to Cloud Run Multi-Region

gcloud run deploy helloworld \
 --platform=managed \
 --allow-unauthenticated \
 --image=gcr.io/mc-mutilcr-spanner/helloworld \
 --region=us-central1

gcloud run deploy helloworld \
 --platform=managed \
 --allow-unauthenticated \
 --image=gcr.io/mc-mutilcr-spanner/helloworld \
 --region=us-east4

gcloud run deploy helloworld \
 --platform=managed \
 --allow-unauthenticated \
 --image=gcr.io/mc-mutilcr-spanner/helloworld \
 --region=us-west1

# Create NEGs

gcloud beta compute network-endpoint-groups create myservice-neg-uscentral1 \
 --region=us-central1 \
 --network-endpoint-type=SERVERLESS \
 --cloud-run-service=helloworld

gcloud beta compute network-endpoint-groups create myservice-neg-useast4 \
 --region=us-east4 \
 --network-endpoint-type=SERVERLESS \
 --cloud-run-service=helloworld

gcloud beta compute network-endpoint-groups create myservice-neg-uswest1 \
 --region=us-west1 \
 --network-endpoint-type=SERVERLESS \
 --cloud-run-service=helloworld

gcloud beta compute backend-services add-backend --global myservice-backend \
 --network-endpoint-group-region=us-central1 \
 --network-endpoint-group=myservice-neg-uscentral1

gcloud beta compute backend-services add-backend --global myservice-backend \
 --network-endpoint-group-region=us-east4 \
 --network-endpoint-group=myservice-neg-useast4

gcloud beta compute backend-services add-backend --global myservice-backend \
 --network-endpoint-group-region=us-west1 \
 --network-endpoint-group=myservice-neg-uswest1

# Configure DNS

gcloud compute addresses describe --global myservice-ip --format='value(address)'

# Update your domain's DNS records by adding an A record with this IP address.

# Verification of Global LB

dig A +short gcp-eng.com

gcloud beta compute ssl-certificates describe myservice-cert

## HTTP to HTTPS redirect

gcloud compute url-maps import myservice-httpredirect \
 --global \
 --source /dev/stdin <<EOF
name: myservice-httpredirect
defaultUrlRedirect:
redirectResponseCode: MOVED_PERMANENTLY_DEFAULT
httpsRedirect: True
EOF

gcloud compute target-http-proxies create myservice-http \
 --url-map=myservice-httpredirect

gcloud compute forwarding-rules create --global myservice-httplb \
 --target-http-proxy=myservice-http \
 --address=myservice-ip \
 --ports=80
