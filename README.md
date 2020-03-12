# MikroTik_Blocklist-DL
Linux shell script to download blocklists of malicious IPs and turn them into MikroTik scripts to import to firewall address lists

This project is a Linux shell script to download malicious IP blocklists from multiple internet sources, then strip the text files down to nothing but IPs or CIDR networks on each line of the text, then using shell tools to parse the list and produce MikroTik scripts to import them as firewall address lists.  

For the first version, I have the script running on a webserver in the same room as my MikroTik RB951g router.  The shell script produces .rsc files in the root directory of my webserver and the System Scheduler on the router has a few lines to script the retrieval and import of the .rsc files.  

The Linux shell script is named "downloadBlocklists.sh" and could be adjusted to suit probably any kind of environment.  I wrote this to replace a system I had been using for years which stopped working in Feb. 2020 when the site went down.  The site I was using to get these kinds of MikroTik malicious IP block lists from said "You may freely use, distribute, copy, modify, and use this blacklist however you like." within their .rsc scripts, so I've taken inspiration from the way those scripts were made and built a Linux shell script to reproduce them from currently available blacklists such as SpamHaus DROP and EDROP, dshield ALL, blocklist.de ALL

Anyone who wants to use this script can download, copy, or modify it anyway you like, subject to the legal limitations as required by law in their land whatever they may be.  You may not copy this shell script I wrote somewhere else and say you wrote it yourself, because that would be lame.  
