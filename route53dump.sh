#!/bin/bash

# CSV output file
output_csv="dns_a_records.csv"

# Function to list the type A records of a hosted zone
list_a_records() {
  local hosted_zone_id=$1
  aws route53 list-resource-record-sets --hosted-zone-id "$hosted_zone_id" --query "ResourceRecordSets[?Type=='A']" --output json
}

# CSV header
echo "HostedZoneId,DomainName,RecordType,TTL,Value" > "$output_csv"

# List all the hosted zones
hosted_zones=$(aws route53 list-hosted-zones --query "HostedZones[*].Id" --output text)

# Iterate on each hosted zone and list the records of type A
for hosted_zone_id in $hosted_zones; do
  echo "Processing Hosted Zone: $hosted_zone_id"
  a_records=$(list_a_records "$hosted_zone_id")

  # Extract information and add to CSV
  echo "$a_records" | jq -r --arg hosted_zone_id "$hosted_zone_id" '.[] | [$hosted_zone_id, .Name, .Type, .TTL, .ResourceRecords[].Value] | @csv' >> "$output_csv"
done

echo "Export completed. The file $output_csv has been created."
