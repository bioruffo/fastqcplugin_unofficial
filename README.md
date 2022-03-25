# README #

This is a mirror of Matt Dyer's FastQC plugin for Ion Torrent Servers (version 3.4.1.1, 01/09/2013), which is itself a wrapper around Babraham institute's FastQC program.  
It is an unofficial version, with the purpose of fixing the plugin's behavior on Ion Proton servers.  

FastQC program: [http://www.bioinformatics.bbsrc.ac.uk/projects/fastqc/](http://www.bioinformatics.bbsrc.ac.uk/projects/fastqc/)  
FastQC plugin: [https://ioncommunity.thermofisher.com/docs/DOC-2602](https://ioncommunity.thermofisher.com/docs/DOC-2602)

The current version is 3.4.1.1.b.

**Installation**  

Download the current plugin .zip archive here: [FastQC-3.4.1.1.b-UNOFFICIAL.zip](https://bitbucket.org/bioruffo/fastqcplugin_unofficial/downloads/FastQC-3.4.1.1.b-UNOFFICIAL.zip)  
To install it, go to the Plugins page of your Torrent Server, select "install or Upgrade Plugin" and upload the .zip archive to the server. Installation should be automatic and the plugin should now be marked as version "3.4.1.1.b".

** Changelog **  

v. 3.4.1.1.a:  
 * Script runs successfully on IonProton, by trying to run on mapped BAMs if present. Will show a representative image from the first valid BAM if no cumulative BAM exists.  

v. 3.4.1.1.b:  
 * Script will display, as representative image, the .bam with the highest file size, including both in the main result directory and the `basecaller_results` subdirectory.  
 
 **Disclaimer**  
This software is provided as-is, and the author disclaims all warranties for for any special, direct, indirect, or consequential damages or any damages whatsoever resulting from loss of use, data or profits, whether in an action of contract, negligence or other tortious action, arising out of or in connection with the use or performance of this software.  

The FastQC software by Babraham Bioinformatics, which is included in the download file together with the script (as it was in the official 3.4.1.1 version), is licensed under a GNU General Public License, that can be found under FastQC/LICENSE.txt.

The wrapper scripts are by Matt Dyer from Ion Torrent Systems, Inc.
