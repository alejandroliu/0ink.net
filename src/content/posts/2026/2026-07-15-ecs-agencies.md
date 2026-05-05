---
title: ECS Agencies in T Cloud Public
date: "2026-05-05"
author: alex
tags: service, security, cloud, password, scripts, settings, address, authentication,
  information
---
[TOC]


![T Cloud Public Logo]({static}/images/2026/T-Cloud-Public-2.png)


Using **Temporary Agency Tokens** (also known as Metadata Service tokens) is the _"gold standard"_
for security on T Cloud Public. It allows your ECS to authenticate without you ever hardcoding an
AK/SK or password in your scripts.

The ECS "borrows" the permissions of an **IAM Agency** assigned to it.

# Step 1: Create an IAM Agency

Before you can use tokens, you must give the ECS permission to act.

1. In the OTC Console, go to **IAM > Agencies**.
2.  Create a new Agency:
   * **Agency Type:** Cloud Service.
   * **Cloud Service:** ECS.
   * **Permissions:** Add the `DNS Administrator` role (to allow the DNS challenge).
3. Go to your **ECS instance settings** and "Modify" the instance to associate it with this new
   Agency.

# Step 2: Retrieve the Token via Metadata Service

Once the agency is attached, the ECS can talk to a local non-routable IP address
(`169.254.169.254`) to get security credentials.


You can fetch a temporary token using `curl` from inside your ECS:

```bash
# Get the temporary security credentials
curl -s http://169.254.169.254/openstack/latest/securitykey
```

The response will contain a temporary `Access`, `Secret`, and `SecurityToken`.

# Step 3: Using the Token

You can now use the security token to issue REST API call.  Note that the token is
a temporary AK/SK with Security Token.  This means that you need to sign your request.

I am using this [script](https://github.com/alejandroliu/0ink.net/blob/main/snippets/2026/curler.py)
script to issue REST API calls.

Usage: `aksk_apicall` _[-h] _[--metadata METADATA | --ak AK]_ _[--sk SK]_ _[--token TOKEN]_ _[--version]_
**{GET,PUT,POST,DELETE}** **url** _[body]_

Calls T Cloud Public API using AK/SK credentials

positional arguments:

* **{GET,PUT,POST,DELETE}** : REST API verb
* _url_ : End-point URL
* _body_ : JSON text body (if needed, usually for **PUT** or **POST** requests).  Use `@filename`
  to read the body from `filename`.

options:

* `-h`, `--help` : show this help message and exit
* `--metadata`, `-m` _METADATA_ : Retrieve credentials from the given MetadataURL
* `--ak`, `--access-key`, `-a` _AK_  : Specified Access Key (or environment: `OS_ACCESS_KEY`)
* `--sk`, `--secret-key`, `-s` _SK_ : Specified Secret Key (or environment: `OS_ACCESS_SECRET`)
* `--token`, `--security-token`, `-t` _TOKEN_ : Specified Secret Key (or environment: `OS_ACCESS_TOKEN`)
* `--version`, `-V` : show program's version number and exit

Should work with Permanent and Temporary AK/SK pairs, if no authentication information is
provided it will automatically retrieve it rom the previously mentioned Metadata URL.

Example use:

```bash
python3 curler.py GET https://dns.eu-de.otc.t-systems.com/v2/zones | jq .
```

# Example use case

You can use this with [certbot](https://certbot.eff.org/) to issue 
[Let's Encrypt](https://letsencrypt.org/) for your VMs.  You just need to implement a
**Manual Auth Hook** to call the T Cloud Public DNS API to set-up the necessary ACME
challenge strings.

![Let's Encrypt]({static}/images/2026/letsencrypt-logo-horizontal.svg)


## A Small Heads-up

Using temporary tokens with Certbot is a bit "DIY" because most ACME clients (like `acme.sh` or
`lego`) are hard-coded to look for static AK/SK environment variables. They don't always know how
to handle the `X-Security-Token` header required for temporary credentials.

Still, this is the most secure way to handle automated renewals. Because standard ACME clients
don't always natively "poll" the metadata service for the `X-Security-Token`, you need to use
Certbot's **Manual Hooks**.

# Using Terraform

All of this can be configured via [Open Tofu](https://opentofu.org/).

Here's a complete example:

## The Three Resources You Need

**1. Create the Agency** — using `opentelekomcloud_identity_agency_v3`:

The `opentelekomcloud_identity_agency_v3` resource creates the agency and assigns roles in one block. The `delegated_domain_name` sets which cloud service is trusted (for ECS, use `op_svc_ecs`), and `project_role` defines the permissions.

```hcl
resource "opentelekomcloud_identity_agency_v3" "ecs_agency" {
  name                 = "my-ecs-agency"
  description          = "Agency for ECS temporary credentials"
  delegated_domain_name = "op_svc_ecs"   # Trusts the ECS service

  project_role {
    project = "eu-de"                    # Your OTC project/tenant name
    roles   = ["OBS OperateAccess"]      # Replace with the roles you need
  }
}
```


**2. Create the ECS VM** — using `opentelekomcloud_ecs_instance_v1`:

The `opentelekomcloud_ecs_instance_v1` resource manages the VM. The agency is assigned by name via the `agency_name` metadata field.

```hcl
resource "opentelekomcloud_ecs_instance_v1" "my_vm" {
  name              = "my-server"
  image_id          = var.image_id
  flavor            = "s3.medium.2"
  vpc_id            = var.vpc_id
  availability_zone = "eu-de-01"
  key_name          = var.key_pair

  nics {
    network_id = var.network_id
  }

  # Assign the agency to this VM
  metadata = {
    agency_name = opentelekomcloud_identity_agency_v3.ecs_agency.name
  }

  depends_on = [opentelekomcloud_identity_agency_v3.ecs_agency]
}
```

**3. Wire it together with `depends_on`** to ensure the agency exists before the VM is created (shown above).

---

## Important Notes

**Permissions required:** For agency creation, your Terraform user needs to have the corresponding
IAM permissions (security admin), which are different from what's required to authorize via the console.

On the other hand, configuring an existing agency for an ECS only requires being an
**administrator or an IAM user with ECS permissions**. This is a much lower bar — essentially anyone
who can create or modify ECS instances can assign an already-existing agency to one.

If you have a separation-of-duties scenario where:
- A **security/IAM admin** creates and manages the agency (once, as a one-off)
- A **developer/ops user** just deploys VMs and assigns the agency

...then the developer only needs standard ECS permissions (`ECS FullAccess` or equivalent). They can
reference the pre-existing agency by name in the `metadata` block without needing any IAM privileges
at all:

```hcl
resource "opentelekomcloud_ecs_instance_v1" "my_vm" {
  # ... standard ECS fields ...

  metadata = {
    agency_name = "my-existing-agency"   # Just a name reference, no IAM needed
  }
}
```

So in short: **no IAM/security-admin permissions are needed** just to attach an existing agency to
a VM. That operation goes through the ECS API, not the IAM API.

**`delegated_domain_name` for ECS:** For ECS instances specifically, use `"op_svc_ecs"` as the
service principal. The example from the docs uses `"op_svc_cce"` for CCE clusters — make sure you
use the right one for ECS.

**Role names:** Use the exact IAM role names as they appear in the OTC console (e.g.,
`"OBS OperateAccess"`, `"Tenant Administrator"`, etc.). You can also use `domain_role` instead
of `project_role` if you want domain-level (cross-project) permissions:

```hcl
resource "opentelekomcloud_identity_agency_v3" "ecs_agency" {
  name                  = "my-ecs-agency"
  delegated_domain_name = "op_svc_ecs"

  domain_role = ["OBS Administrator"]   # Domain-level role
}
```

# Why this is better:

* **No Credentials on Disk:** If your server is compromised, there are no permanent keys to steal.
* **Automatic Rotation:** The tokens expire automatically (usually after 24 hours), and the
  ECS service handles the rotation behind the scenes.
* **Centralized Control:** You can revoke the ECS's ability to edit DNS records instantly by
  removing the Agency from the IAM console, without touching the server.
* **Audit Trail:** T Cloud Public logs will show the Agency performing these actions, making it
  easy to track in Cloud Eye / Cloud Trace Service.

