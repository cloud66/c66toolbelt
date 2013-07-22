# Cloud 66 Toolbelt: c66

Cloud 66 Toolbelt is a simple command-line tool for the awesome Cloud 66 customers. It allows you to deploy, modify settings and retrieve the current status of your Cloud 66 stacks, and much more!

## Installation

You can install the Cloud 66 Toolbelt using [RubyGems](http://rubygems.org/):

    $ gem install c66

## Usage

### Help
With c66 installed, you can display the help with one of the following instructions:

	$ c66 help

or

	$ c66

### Initialize the Toolbelt

Firstly, to use the Toolbelt, you will need to initiate it using:

	$ c66 init

Then visit the URL given once authorized, copy and paste the `authorization code` into the command-line interface.

You need to sign in and allow the Cloud 66 Toolbelt application to use your account to access to the authorization code.

Note: This is a one-off task.

### List the Stacks

You can list all your stacks using:

	$ c66 list

### Deploy a Stack

Deploy a stack using the command `deploy` with a stack UID (Unique Identifer):

	$ c66 deploy --stack <stack_UID>

or

	$ c66 deploy -s <stack_UID>

You can retrieve the UID of a stack using the `list` command.

Through the Cloud 66 interface, click on your stack, then click on the cog and select the stack information view to retrieve the UID:

![stack_uid](http://cdn.cloud66.com.s3.amazonaws.com/images/Toolbelt/exemple_stack_uid.PNG)

The stack UID is saved when you deploy through the Cloud 66 Toolbelt. It allows you to deploy a stack without putting the stack UID every time:

	$ c66 deploy

you can use a short-cut for this command:

	$ c66 d

### Settings of a Stack

It is possible to retrieve the settings of a specified stack and to easily modify them:

To display the settings:

	$ c66 settings --stack <stack_UID>

or

	$ c66 settings -s <stack_UID>

If your stack UID is saved:

	$ c66 settings

To modify a setting:

	$ c66 set --stack <stack_UID> --setting_name <setting_name> --value <value>

or

	$ c66 set -s <stack_UID> -n <setting_name> -v <value>

If the stack UID is saved:

	$ c66 set --setting_name <setting_name> --value <value>

or 

	$ c66 set -n <setting_name> -v <value>


## Contributing

1. Fork it

2. Create your feature branch (`git checkout -b my-new-feature`)

3. Commit your changes (`git commit -am 'Add some feature'`)

4. Push to the branch (`git push origin my-new-feature`)

5. Create new Pull Request

## Copyright

Copyright (c) 2013 Cloud66 Limited.. See LICENSE for details.