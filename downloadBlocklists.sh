#!/bin/bash
# Script to download, filter, and format lists of known-bad IP addresses

## Clear work directory for new files
rm -f ~/MT/spamhau*.txt
rm -f ~/MT/spamhau*.rsc
rm -f ~/MT/dshiel*.txt
rm -f ~/MT/dshiel*.rsc
rm -f ~/MT/blocklist*.txt
rm -f ~/MT/blocklist*.rsc

## This section downloads the Spamhaus DROP and EDROP lists into one DL.txt, then removes duplicate entries
wget -qO- https://www.spamhaus.org/drop/drop.txt | egrep --only-matching -E  '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)/[[:digit:]]+' > ~/MT/spamhausDL.txt

wait

wget -qO- https://www.spamhaus.org/drop/edrop.txt | egrep --only-matching -E  '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)/[[:digit:]]+' >> ~/MT/spamhausDL.txt

wait

sort -fs ~/MT/spamhausDL.txt | uniq -i > ~/MT/spamhaus.txt

wait

## This section downloads two similar blacklists from dshield.org into one DL.txt, then removes duplicate entries, then appends "/24" to the end of each line because it needs that
wget -qO- https://www.dshield.org/block.txt | egrep --only-matching -E  '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.([0])' > ~/MT/dshieldDL.txt

wait

wget -qO- https://feeds.dshield.org/block.txt | egrep --only-matching -E  '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.([0])' >> ~/MT/dshieldDL.txt

sort -fs ~/MT/dshieldDL.txt | uniq -i > ~/MT/dshield.txt

wait

sed -e 's/$/\/24/' -i ~/MT/dshield.txt

wait

## This section downloads a huge-ass list of bad IPs from blocklist.de, then removes duplicate entries
wget -qO- https://lists.blocklist.de/lists/all.txt | egrep --only-matching -E  '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)' > ~/MT/blocklist-deDL.txt

wait

sort -fs ~/MT/blocklist-deDL.txt | uniq -i > ~/MT/blocklist-de.txt

wait

## This section adds stuff to the .txt files and makes them into MikroTik RouterOS scripts
sed -e 's/^/\/do \{ip firewall address-list add list=SpamHaus address=/' -i ~/MT/spamhaus.txt

wait

sed -e 's/$/\} on-error=\{\}/' ~/MT/spamhaus.txt > ~/MT/spamhaus.rsc

wait

sed -i '1s/^/\/ip firewall address-list\n/' ~/MT/spamhaus.rsc

wait

sed -i '1s/^/\/ip firewall address-list remove [find list="SpamHaus"]\n/' ~/MT/spamhaus.rsc

wait

sed -i '1s/^/\/system logging disable 0\n/' ~/MT/spamhaus.rsc

wait

sed -e 's/^/\/do \{ip firewall address-list add list=Dshield address=/' -i ~/MT/dshield.txt

wait

sed -e 's/$/\} on-error=\{\}/' ~/MT/dshield.txt > ~/MT/dshield.rsc

wait

sed -i '1s/^/\/ip firewall address-list\n/' ~/MT/dshield.rsc

wait

sed -i '1s/^/\/ip firewall address-list remove [find list="Dshield"]\n/' ~/MT/dshield.rsc

wait

sed -i '1s/^/\/system logging disable 0\n/' ~/MT/dshield.rsc

wait

sed -e 's/^/\/do \{ip firewall address-list add list=blocklistDE address=/' -i ~/MT/blocklist-de.txt

wait

sed -e 's/$/\} on-error=\{\}/' ~/MT/blocklist-de.txt > ~/MT/blocklist-de.rsc

wait

sed -i '1s/^/\/ip firewall address-list\n/' ~/MT/blocklist-de.rsc

wait

sed -i '1s/^/\/ip firewall address-list remove [find list="blocklistDE"]\n/' ~/MT/blocklist-de.rsc

wait

sed -i '1s/^/\/system logging disable 0\n/' ~/MT/blocklist-de.rsc

wait

sleep 10

## Next we need to transfer the .rsc files to the MT router
## This part may need admin privs
rm -f /var/www/html/*.rsc

cp ~/MT/*.rsc /var/www/html/

## run scheduler scripts on MT router to download and import the .rsc's
## 
## /tool fetch address=yoursite.com host=yoursite.com mode=https port=443 src-path=/spamhaus.rsc
## /tool fetch address=yoursite.com host=yoursite.com mode=https port=443 src-path=/dshield.rsc
## /tool fetch address=yoursite.com host=yoursite.com mode=https port=443 src-path=/blocklist-de.rsc
##
## :log warning "Disabling system Logging and Importing blocklists";
## import spamhaus.rsc
## import dshield.rsc
## import blocklist-de.rsc
## /system logging enable 0
## :log warning "Done Importing blocklists and system Logging is Enabled";
## 
## Last - use firewall rules to Drop Input from each Address List
