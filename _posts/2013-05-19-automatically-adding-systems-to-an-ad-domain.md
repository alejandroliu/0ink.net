---
ID: "217"
post_author: "2"
post_date: "2013-05-19 17:10:07"
post_date_gmt: "2013-05-19 17:10:07"
post_title: Automatically adding systems to an AD domain
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: automatically-adding-systems-to-an-ad-domain
to_ping: ""
pinged: ""
post_modified: "2013-05-19 17:10:07"
post_modified_gmt: "2013-05-19 17:10:07"
post_content_filtered: ""
post_parent: "0"
guid: http://s12.pw/wp/?p=217
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: Automatically adding systems to an AD domain
...
---

When using virtualisation it is very common to create <em>template</em> VMs that can be cloned from.  This makes deployment much easier than having to install a new VM from scratch.

Unfortunately, the cloned VMs lack any Active Directory memberships and the VMs have to be <em>manually</em> added to the AD domain.  For automated deployment scenarios this is less than desirable.

This recipe intends to solve that issue in a <em>Hypervisor</em> independant manner.

This recipe uses a Visual Basic script that will automatically join a system to a domain during Windows system preparation. In Lab Manager these steps can be performed on a VM Template so that virtual machines cloned from it will be joined to the domain when the system customization process runs. A specific Active Directory Organizational Unit can be specified.

The Visual Basic script will contain credentials used for joining the system to the domain. So, as a security measure the Visual Basic script is setup to be deleted at the end of a successful execution.

<h2>Prerequisites</h2>

<ul>
<li>Active Directory User Account with permissions to add Computer Objects.</li>
<li>LDAP path syntax to Active Directory Organizational Unit to add the Computer to. </li>
</ul>

<h2>Steps on the VM Template</h2>

<h3>Create Scripts Folder</h3>

<code>C:WindowsSetupScripts</code>

<h3>Create Batch File</h3>

<code>C:WindowsSetupSetupComplete.cmd</code>

<pre><code>Start /wait cscript&amp;nbsp;%WINDIR%SetupScriptsAddDomain.vbs
Del %WINDIR%SetupScriptsAddDomain.vbs
</code></pre>

<h3>Create VBS File</h3>

<code>C:WindowsSetupScriptsAddDomain.vbs</code>

<pre><code>Const JOIN_DOMAIN             = 1
Const ACCT_CREATE             = 2
Const ACCT_DELETE             = 4
Const WIN9X_UPGRADE           = 16
Const DOMAIN_JOIN_IF_JOINED   = 32
Const JOIN_UNSECURE           = 64
Const MACHINE_PASSWORD_PASSED = 128
Const DEFERRED_SPN_SET        = 256
Const INSTALL_INVOCATION      = 262144

strDomain   = "DomainName"
strOU       = "LDAPOUPATH"
strUser     = "DomainUsername"
strPassword = "Password"

Set objNetwork = CreateObject("WScript.Network")
strComputer = objNetwork.ComputerName

Set objComputer = _
  GetObject("winmgmts:{impersonationLevel=Impersonate}!" &amp; _
  strComputer &amp; "rootcimv2:Win32_ComputerSystem.Name='" _
  &amp; strComputer &amp; "'")

ReturnValue = objComputer.JoinDomainOrWorkGroup(strDomain, _
   strPassword, _
   strDomain &amp; "" &amp;amp; strUser, _
   strOU, _
   JOIN_DOMAIN + ACCT_CREATE)
</code></pre>

Tip: Start Notepad as administrator to have save access to the folder.

Set the correct values for <code>StrDomain</code>, <code>StrOU</code>, <code>StrUser</code> and <code>StrPassword</code>

Example:

<pre><code>    strDomain = "best.adinternal.com" 
    strOU = "ou=Virtuals,ou=CRE R&amp;D,ou=Beaverton,ou=Shared Management,dc=best,dc=adinternal,dc=com" 
    strUser&amp; = "_adjoinuser" 
    strPassword = "$uperS3curePassw()rd!{13245}" 
</code></pre>

<h2>Deploy VM</h2>

Be sure <code>Perform customization</code> is checked and <code>Microsoft Sysprep</code> is selected on the VM Template properties.

<code>Clone the VM Template</code>

Tip: Wait around 10 minutes before trying to login to the VM. During this time the VM is going through the sysprep process which will change the hostname to the name specified when cloning the VM to a configuration and join the domain. The process should be complete when the login screen displays <strong>[Ctrl]+[Alt]+[Delete]</strong> and prompts for a domain login.

<h2>Additional notes</h2>

To improve security we could for example not hardcode login credentials in the VB script.  Instead, we could retrieve them from a web server (using SSL).  This server could reset the Login password for the addDomain account and send that.  Once this is completed, the password could be reset again.

Also, the web server could check the IP address and referencing DNS/DHCP to see if this machine is indeed being authorised.

Finally, we can place this in a different AD domain (with the appropriate trust relationships) so that you can apply additional security policies.

<h2>References</h2>

<ul>
<li>This recipe was originally published at: <a href="http://www.bonusbits.com/main/HowTo:Setup_a_VM_to_Automatically_Join_to_a_Domain">http://www.bonusbits.com/main/HowTo:Setup_a_VM_to_Automatically_Join_to_a_Domain</a><br />
Unfortunately I am no longer able to reach this site.</li>
<li><a href="http://kb.vmware.com/selfservice/microsites/search.do?language=en_US&amp;cmd=displayKC&amp;externalId=1007491">http://kb.vmware.com/selfservice/microsites/search.do?language=en_US&amp;cmd=displayKC&amp;externalId=1007491</a></li>
<li><a href="http://msdn.microsoft.com/en-us/library/windows/desktop/aa392154%28v=vs.85%29.aspx">http://msdn.microsoft.com/en-us/library/windows/desktop/aa392154%28v=vs.85%29.aspx</a></li>
</ul>

Other examples:

<ul>
<li><a href="http://mail-archives.apache.org/mod_mbox/incubator-vcl-user/201112.mbox/%3CCAD7o_XxD2a9j0+V7faE1nTSt-OMT+W9=y4TCvKZ-3q92+czewQ@mail.gmail.com%3E">http://mail-archives.apache.org/mod_mbox/incubator-vcl-user/201112.mbox/%3CCAD7o_XxD2a9j0+V7faE1nTSt-OMT+W9=y4TCvKZ-3q92+czewQ@mail.gmail.com%3E</a></li>
<li><a href="http://www.virtualizationteam.com/virtualization-vmware/vcloud-director/vcloud-director-joining-vms-to-specific-active-directory-domain-ou.html">http://www.virtualizationteam.com/virtualization-vmware/vcloud-director/vcloud-director-joining-vms-to-specific-active-directory-domain-ou.html</a></li>
<li><a href="http://itnervecenter.com/content/deploying-window-server-2008-r2-vmware-template-and-joining-it-domain">http://itnervecenter.com/content/deploying-window-server-2008-r2-vmware-template-and-joining-it-domain</a></li>
<li><a href="http://blogs.citrix.com/2011/09/16/xenclient-auto-join-vms-to-the-activedirectory/">http://blogs.citrix.com/2011/09/16/xenclient-auto-join-vms-to-the-activedirectory/</a></li>
</ul>

