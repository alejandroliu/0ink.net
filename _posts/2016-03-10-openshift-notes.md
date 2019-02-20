---
title: OpenShift notes
---

**THIS IS FOR ARCHIVAL PURPOSES.  THIS IS OUT-OF-DATE**

## backup OpenShift

```
openshift getenv(USER) from OpenShift php
ssh to {user}@{app-domain} gear snapshot  > file
```

Run gear app


OpenShift migration further notes

Encrypt a file using a supplied password :

```
$ openssl enc -aes-256-cbc -salt -in file.txt -out file.txt.enc -k PASS
```

Decrypt a file using a supplied password :

```
$ openssl enc -aes-256-cbc -d -in file.txt.enc -out file.txt -k PASS
```

Add script to tar plugin, then rhc a SSH key into account,
ssh to account and tar x data...

1. get target directory
2. clean-up target directory
3. extract new contents

Probably can use deploy as an example...

- need to list images that have been uploaded to S3.
- need to convert imgsrc references...

? wordpress filters vs hooks ?

Sample stuff:

- [writing a plugin](https://codex.wordpress.org/Writing_a_Plugin#Saving_Plugin_Data_to_the_Database)
- [working with database](https://www.sitepoint.com/working-with-databases-in-wordpress/)
- [creating database](https://premium.wpmudev.org/blog/creating-database-tables-for-plugins/)

Skeleton

- [plugin template](https://github.com/convissor/oop-plugin-template-solution)
- [plugin class](http://wordpress.stackexchange.com/questions/44708/using-a-plugin-class-inside-a-template)
- [how to write wordpress plugin](http://www.yaconiello.com/blog/how-to-write-wordpress-plugin/)

[Mangle data when saving](http://wordpress.stackexchange.com/questions/35931/how-can-i-edit-post-data-before-it-is-saved)

[post types](https://codex.wordpress.org/Post_Types)
... perhaps we add an S3 flag to the post type: Attachment

# WordPress

Standard Customizations:

1. Appearance
   - Set theme
   - Site Identity
   - Header & Background iamge
   - Menus: Set-up top bar?
2. Settings
   - General Settings
     1. Membership: Not anyone can register
     2. Timezone UTC
     3. Date/Time Format
   - Reading
     1. For each article in the feed: Show full text
   - Discussion
     1. Users must be registered to comment.  Not fill out name+email
     2. Comments author must have previously approved comment
   - Permalinks
     1. Month and name

   
Plugins

- Front Page Category
  - Customizer, Front Page Categories, select what to show
- Collapsing category list
  - Customizer, Widgets, Categories, customize...
- bbPress
  - NO anonymous posting
- WP Social Login
  - Bouncer
   - Allow Username change
- Rich Revies
  - Integrate user accounts

# OpenShift Recipe

The official deploy tool [dpl](https://github.com/travis-ci/dpl) does not 
seem to work with secondary branches.

## Pre-requisistes

1. Install git
2. Install RHC command line
   - yum install epel-release
   - yum install rubygem-rhc
3. Install Travis command line
   - yum install epel-release
   - yum install ruby-devel rubygem-ffi (maybe others)
   - gem install travis -v 1.8.2 --no-rdoc --no-ri
4. A github, travis-ci and opens

## Preparing Repo

This section can be skipped if we already have a github repo.

1. Fork [wordpress-example](https://github.com/openshift/wordpress-example.git)
2. Create any additional branches as needed.
3. Configure travis-ci by creating a basic `.travis.yml`
   - language: php
   - php:
   - - '5.4'
   - script: true
4. Since `travis setup openshift` doesn't work, we need to use the DIY
   deploy script.  So make a copy of it.  And configure:
   - env:
   - \_ global:
   - \_\_ OPENSHIFT\_USER=$username
   - \_\_ OPENSHIFT\_SECRET=$secret
     1. Obviously the secret should be encrypted using:
        - travis encrypt OPENSHIFT\_SECRET=$secret [--add env.global]
   - script:
   - - sh deploy.sh
   - diydeploy:
   - - deploy $branch:$openshift_app ... initially empty...

## Deploying Repo to OpenShift App

1. Create a new Application from the Openshift
   [console](https://www.openshift.com/).
   - Use (WordPress 4)
   - Just leave initial repo to the default
   - Decide on scaling options.
   - DO NOT GO THROUGH SITE INSTALL YET!
2. Add the $branch:$openshift_app to the `.travis.yml`, and push so
   travis-ci will deploy.
3. Tweak configuration:
   - force https through .htaccess.
   - Enable MULTISITE (if needed)
4. Enable custom domain
   - Create Domain Name (on DNS) and add custom domain in OpenShift
   - Add Certificate to OpenShift (self-signed or maybe CloudFlare)
     - openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 3650 -nodes
   - Wait for DNS to propagate
5. Log-on to the site and go through installation.
   - Verify that URLs use https:
    - Dashboard -> Settings -> General
    - Verify in Permalinks that https is used.

* * *

Fork syncing

```
   - Clone repo
   - Configure a remote fork
     1. git remote -v
     2. git remote add upstream https://github.com/openshift/wordpress-example.git
   - Syncing a fork
     1. git fetch upstream
     2. git checkout master
     3. git merge upstream/master




      //define('DOMAIN_CURRENT_SITE', 'dev.iliu.net');
      if ($_SERVER['SERVER_NAME'] != 'dev.iliu.net') {
         define('DOMAIN_CURRENT_SITE', 'iliu.net');
      } else {
         define('DOMAIN_CURRENT_SITE', 'dev.iliu.net');
      }
```

# openshift mailgun

Success! You're signed up and we just created your sandbox server sandboxf9dbaaa2f22a49a693955138381837e7.mailgun.org

# Include the Autoloader (see "Libraries" for install instructions)

```
require 'vendor/autoload.php';
use Mailgun\Mailgun;

# Instantiate the client.
$mgClient = new Mailgun('key-xxxxxxxxxxxxxxxxxxxxxxxxx');
$domain = "sandboxf9dbaaa2f22a49a693955138381837e7.mailgun.org";

# Make the call to the client.
$result = $mgClient->sendMessage("$domain",
                  array('from'    => 'Mailgun Sandbox <postmaster@sandboxf9dbaaa2f22a49a693955138381837e7.mailgun.org>',
                        'to'      => 'Alejandro Liu <alejandro_liu@hotmail.com>',
                        'subject' => 'Hello Alejandro Liu',
                        'text'    => 'Congratulations Alejandro Liu, you just sent an email with Mailgun!  You are truly awesome!  You can see a record of this email in your logs: https://mailgun.com/cp/log .  You can send up to 300 emails/day from this sandbox server.  Next, you should add your own domain so you can send 10,000 emails/month for free.'));
```

* * *

- [free paas mail server](https://blog.openshift.com/free-paas-email-server-with-roundcube/)
- [mailgun](https://blog.openshift.com/email-in-the-cloud-with-mailgun/)
- [mailgun plan](https://mailgun.com/signup?plan=free)
- [forwarding with mailgun](https://www.gregjs.com/linux/2015/forwarding-mail-to-your-gmail-account-with-mailgun/)

