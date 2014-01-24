<h1 class="doc-title">Cloud 66 Toolbelt</h1>
<p class="lead">Cloud 66 Toolbelt is a simple command-line tool for the awesome Cloud 66 customers. It allows you to deploy, modify settings and retrieve the current status of your Cloud 66 stacks, and much more!</p>

## Installation

You can install the Cloud 66 Toolbelt using [RubyGems](http://rubygems.org/):
<p>
<kbd>$ gem install c66</kbd>
</p>

## Help

With c66 installed, you can display the help with one of the following instructions:
<p>
<kbd>$ c66 help</kbd>
</p>
	
or

<p>
<kbd>$ c66</kbd>
</p>

or for a specific command:

<p>
<kbd>$ c66 help &lt;command&gt;</kbd>
</p>

## Initialize the Toolbelt

Firstly, to use the Toolbelt, you will need to initiate it using:

<p>
<kbd>$ c66 init</kbd>
</p>
	
Then visit the URL given once authorized, copy and paste the `authorization code` into the command-line interface.
You need to sign in and allow the Cloud 66 Toolbelt application to use your account to access to the authorization code.

**Note**: This is a one-off task.

## List the Stacks

You can list all your stacks using:

<p>
<kbd>$ c66 list</kbd>
</p>

## Deploy a Stack

Deploy a stack using the command `deploy` with a stack UID (Unique Identifer):

<p>
<kbd>$ c66 deploy --stack &lt;stack_UID&gt;</kbd>
</p>
	
or

<p>
<kbd>$ c66 deploy -s &lt;stack_UID&gt;</kbd>
</p>
	
You can retrieve the UID of a stack using the `list` command.
Through the Cloud 66 interface, click on your stack, then click on the cog and select the stack information view to retrieve the UID:
![stack_uid](http://cdn.cloud66.com.s3.amazonaws.com/images/Toolbelt/exemple_stack_uid.PNG)

There is a command to save a default stack UID:

<p>
<kbd>$ c66 save --stack &lt;stack_UID&gt;</kbd>
</p>
	
or

<p>
<kbd>$ c66 save -s &lt;stack_UID&gt;</kbd>
</p>

**Note:** The stack is saved in your current folder (.cloud66/stack.json) and only one default stack will be saved per folder.

When your stack UID is saved, you are able to use other commands without specify the stack UID.
For instance, it allows you to deploy a stack without putting the stack UID every time:

<p>
<kbd>$ c66 deploy</kbd>
</p>
	
you can use a short-cut for this command:

<p>
<kbd>$ c66 d</kbd>
</p>

You can save multiple stack UID by giving an alias to a specific stack:

<p>
<kbd>$ c66 save --stack &lt;stack_UID&gt; --alias &lt;stack_alias&gt;</kbd>
</p>

Then you can use commands and specific a stack's alias, like so:

<p>
<kbd>$ c66 deploy -s &lt;stack_alias&gt;</kbd>
</p>

## Settings of a Stack

It is possible to retrieve the settings of a specified stack and to easily modify them:

To display the settings:

<p>
<kbd>$ c66 settings --stack &lt;stack_UID&gt;</kbd>
</p>
	
or

<p>
<kbd>$ c66 settings -s &lt;stack_UID&gt;</kbd>
</p>
	
If a default stack UID is saved:

<p>
<kbd>$ c66 settings</kbd>
</p>
	
To modify a setting:

<p>
<kbd>$ c66 set --stack &lt;stack_UID&gt; --setting_name &lt;setting_name&gt; --value &lt;value&gt;</kbd>
</p>
	
or

<p>
<kbd>$ c66 set -s &lt;stack_UID&gt; -n &lt;setting_name&gt; -v &lt;value&gt;</kbd>
</p>
	
If a default stack UID is saved:

<p>
<kbd>$ c66 set --setting_name &lt;setting_name&gt; --value &lt;value&gt;</kbd>
</p>
	
or

<p>
<kbd>$ c66 set -n &lt;setting_name&gt; -v &lt;value&gt;</kbd>
</p>

## Lease an IP address (version &ge; 0.1.91)

You can allow an IP address to connect temporarily to the specific stack through ssh (22):

<p>
<kbd>$ c66 lease --stack &lt;stack_UID&gt; --ip-address &lt;ip_address&gt; --time-to-open &lt;time_to_open&gt;</kbd>
</p>

or

<p>
<kbd>$ c66 lease -s &lt;stack_UID&gt; -i &lt;ip_address&gt; -t &lt;time_to_open&gt;</kbd>
</p>

Options *ip-address* and *time-to-open* are optional.
By default:

- *ip-address* : your IP address
- *time-to-open* : 20 minutes

To allow your own IP address to connect temporarily to the specific stack:

<p>
<kbd>$ c66 lease --stack &lt;stack_UID&gt;</kbd>
</p>

If a default stack UID is saved:

<p>
<kbd>$ c66 lease</kbd>
</p>

## Download an backup (version &ge; 0.1.91)

You can download a backup if you installed <a href="help.cloud66.com/stack-features/db-backup.html" target="_blank">managed backups</a> on your stack. This feature will concatenate separate files into one automatically if your backup consists of numerous files.

<p>
<kbd>$ c66 download_backup -b &lt;backup_id&gt;
</p>

You can retrieve the backup ID by accessing the "Managed backups" page through the Cloud 66 interface. Click on your stack and then on the managed backup icon in front of your database group, and your backup IDs should be visible.

## Information of your toolbelt settings

At any time, you can see your toolbelt settings, it includes the version of the toolbelt but also some information about your saved stacks:
 
<p>
<kbd>$ c66 info</kbd>
</p>

## Contributing

1. Fork it
2. Create your feature branch `git checkout -b my-new-feature`
3. Commit your changes `git commit -am 'Add some feature'`
4. Push to the branch `git push origin my-new-feature`
5. Create new Pull Request
