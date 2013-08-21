require "rubygems"
require "thor"
require "oauth2"
require "json"
require "httparty"

module C66
    module Commands

        CLIENT_NAME = 'c66'
        CLIENT_FULLNAME = 'Cloud 66 Toolbelt'

        STK_QUEUED    = 0
        STK_SUCCESS    = 1
        STK_FAILED    = 2
        STK_ANALYSING     = 3
        STK_ANALYSED    = 4
        STK_QUEUED_FOR_DEPLOYING    = 5
        STK_DEPLOYING    = 6
        STK_TERMINAL_FAILURE    = 7

        FORBIDDEN_STACKS_ALIAS = ['params', 'toolbelt']

        STATUS = {
            STK_QUEUED => 'Pending analysis',
            STK_SUCCESS => 'Deployed successfully',
            STK_FAILED => 'Deployment failed',
            STK_ANALYSING => 'Analyzing',
            STK_ANALYSED => 'Analyzed',
            STK_QUEUED_FOR_DEPLOYING => 'Queued for deployment',
            STK_DEPLOYING => 'Deploying',
            STK_TERMINAL_FAILURE => 'Unable to analyze'
        }

        VERSION_FILE = 'http://cdn.cloud66.com/config/cloud66_toolbelt.json'
        BASE_URL = 'https://www.cloud66.com'

        class C66Toolbelt < Thor
            no_commands {
                def values
                    @values ||=
                    { :base_url => "#{BASE_URL}/api/2",
                    :client_id => "638412995ee3da6f67e24564ac297f9554ee253a8fe1502348c4d6e845bd9d0d",
                    :client_secret => "961398353aa6e7f0f36dfcd83e447d748c54481b7a3b143e0119441516e8b91f",
                    :scope => "public redeploy",
                    :redirect_url => "urn:ietf:wg:oauth:2.0:oob",
                    :auth_url => "#{BASE_URL}/oauth/authorize",
                    :token_url => "#{BASE_URL}/oauth/token"
                    }
                end

                def base_url
                    load_params
                    values[:base_url]
                end

                def c66_path
                    File.join(File.expand_path("~"), ".cloud66")
                end

                def stack_path
                    File.join(File.expand_path("."), ".cloud66")
                end

                def config
                    if @config.nil?
                        load_config
                    end

                    @config
                end

                def config_file
                    File.join(c66_path, "toolbelt.json")
                end

                def params_file
                    File.join(c66_path, "params.json")
                end

                def stack_file(alias_name = nil)
                    if alias_name
                        if alias_name.match(/\w/)
                            File.join(stack_path, "#{alias_name}.json")
                        else
                            abort "#{alias_name} is an invalid alias."
                        end
                    else
                        File.join(stack_path, "stack.json")
                    end
                end

                def load_config
                    if File.exists?(config_file)
                        @config = JSON.load(IO.read(config_file))
                    else
                        abort("No config file found at #{config_file}. Run #{CLIENT_NAME} init to register your client")
                    end
                end

                def save_config
                    if !File.directory?(c66_path)
                        Dir.mkdir(c66_path)
                    end

                    File.open(config_file,"w") do |f|
                        f.write(@config.to_json)
                    end
                end

                def load_stack(alias_name)
                    if File.exists?(stack_file(alias_name))
                        if file = JSON.load(IO.read(stack_file(alias_name)))
                            if file.has_key? 'stack_id' 
                                @stack = file['stack_id']
                            end
                            if file.has_key? 'stack_name' and !@stack.nil?
                                @stack_name = file['stack_name']
                                say "Stack #{@stack_name} loaded."
                            end
                        end
                    end
                end

                def abort_no_stack
                    abort "No stack provided or saved, please use '--stack' or '-s' option. "\
                    "You can also use the 'save' method with '--stack' or '-s' option."
                end

                def load_params
                    if File.exists?(params_file) && File.size(params_file)!=0
                        begin
                            @params= JSON.load(IO.read(params_file))
                        rescue => e
                            abort "#{params_file} is not a valid JSON file"
                        end
                        if @params.has_key? 'base_url'
                            values[:base_url] = @params['base_url']
                        else
                            abort "Missing 'base_url' parameter in #{params_file}"
                        end
                        if @params.has_key? 'client_id'
                            values[:client_id] =  @params['client_id']
                        else
                            abort "Missing 'client_id' parameter in #{params_file}"
                        end
                        if @params.has_key? 'client_secret'
                            values[:client_secret] = @params['client_secret']
                        else
                            abort "Missing 'client_secret' parameter in #{params_file}"
                        end
                        #say "Parameters loaded."
                    end
                end

                def get_stack(stack_id_or_alias_name)
                    if stack_id_or_alias_name && !File.exist?(stack_file(stack_id_or_alias_name))
                        @stack=stack_id_or_alias_name
                    else
                        load_stack(stack_id_or_alias_name)
                    end
                end

                def client
                    @client ||= OAuth2::Client.new(values[:client_id], values[:client_secret], :site => values[:base_url])
                end

                def token
                    load_config

                    if @config.has_key? 'token'
                        OAuth2::AccessToken.new(client, @config['token'])
                    else
                        abort "No authentication token found. run #{CLIENT_NAME} init to register your client"
                    end
                end

                def parse_response(response)
                    begin
                        JSON.parse(response.body)
                    rescue => e
                        abort e.message
                    end
                end

                def error_message(error)
                    begin
                        if !error.response.parsed.nil?
                            if (error.response.parsed.has_key? 'details')
                                puts error.response.parsed['details']
                            else                   
                                puts error.response.parsed['error_description']
                            end
                        end
                    rescue => e
                        abort e.message
                    end
                end

                def get_version
                    begin
                        JSON.load(HTTParty.get(VERSION_FILE).response.body).fetch("version")
                    rescue => e
                        puts "Failed to retrieve the latest version of Cloud 66 Toolbelt, please contact us"
                    end
                end

                def display_info
                    say "#{CLIENT_FULLNAME} version #{C66::Utils::VERSION}\n\n"
                end

                def compare_versions
                    result = C66::Utils::VERSION <=> Gem::Version.new(get_version)
                    case result
                    when 0..1
                        #say "Version is up-to-date."
                    when -1
                       say "There is a new version of Cloud66 Toolbelt. Pease run \"gem update #{CLIENT_NAME}\".",:red
                    end
                end

                # def pending_intercom_messages
                #     begin
                #         result = parse_response(token.get("#{base_url}/users/unread_messages.json"))
                #         nb_messages = result['response']['unread_messages']
                #         say "You have #{nb_messages} pending message(s), check them out at www.cloud66.com !",:green if nb_messages > 0
                #     rescue 
                #         # nop
                #     end
                # end

                def before_each_action
                    compare_versions
                    # pending_intercom_messages
                end
            }

            package_name "#{CLIENT_FULLNAME}: version #{C66::Utils::VERSION}\n"

            default_task :default

            desc "default", "hidden method", :hide => true
            def default
                before_each_action
                help
            end

            desc "init", "Initialize the toolbelt"
            map "d" => :deploy
            long_desc <<-LONGDESC
            Initialize Cloud 66 toolbelt
            LONGDESC
            def init
                load_params
                result = client.auth_code.authorize_url(:redirect_uri => values[:redirect_url], :scope => values[:scope])

                say "Visit the URL below and paste the initialization code here"
                say result

                auth_code = ask("Authorization Code:")

                begin
                    token = client.auth_code.get_token(auth_code, :redirect_uri => values[:redirect_url])
                rescue OAuth2::Error => e
                    abort e.message
                end

                @config = { :auth_code => auth_code, :token => token.token, :refresh_token => token.refresh_token }
                save_config

                say "Configuration saved to #{config_file}"
            end

            desc "list", "Lists all the stacks"
            def list
                before_each_action
                begin
                    response = parse_response(token.get("#{base_url}/stacks.json"))

                    if response['count'] != 0
                        response['response'].each do |stack|
                            say "#{stack['name']} (#{stack['uid']}) : #{stack['environment']} - #{STATUS[stack['status']]}"
                        end
                    else
                        say "No stacks found"
                    end
                rescue OAuth2::Error => e
                    error_message(e)
                end
            end

            desc "settings", "Get the list of settings for this stack"
            option :stack, :aliases => "-s", :required => false
            def settings
                before_each_action
                begin
                    get_stack(options[:stack])
                    abort_no_stack if @stack.nil?
                    response = token.get("#{base_url}/stacks/#{@stack}/settings.json")
                    settings = JSON.parse(response.body)['response']
                    number_settings = JSON.parse(response.body)['count']
                    stack_details = parse_response(token.get("#{base_url}/stacks/#{@stack}.json"))
                    stack_name = stack_details['response']['name']

                    abort "No settings found" if settings.nil?
                    say "Getting #{stack_name} settings:"
                    settings.each do |setting|
                        say "#{setting['key']}\t\t#{setting['value']}\t#{setting['readonly'] ? '(readonly)' : ''}\r\n"
                   end
                rescue OAuth2::Error => e
                    error_message(e)
                end
            end

            desc "set", "Set the value of a specific setting"
            option :stack, :aliases => "-s", :required => false
            option :setting_name, :aliases => "-n", :required => true
            option :value, :aliases => "-v", :required => true
            def set()
                before_each_action
                begin
                    get_stack(options[:stack])
                    abort_no_stack if @stack.nil?
                    stack_details = parse_response(token.get("#{base_url}/stacks/#{@stack}.json"))
                    stack_name = stack_details['response']['name']
                    response = token.post("#{base_url}/stacks/#{@stack}/setting.json", { :body => { :setting_name => options[:setting_name], :setting_value => options[:value] }})
                    say "On #{stack_name}: applied value '#{options[:value]}' to setting '#{options[:setting_name]}'" if JSON.parse(response.body)['response']['ok']
                rescue OAuth2::Error => e
                    error_message(e)
                end
            end

            desc "deploy", "Deploy the given stack"
            option :stack, :aliases => "-s", :required => false
            def deploy
                before_each_action
                begin
                   get_stack(options[:stack])
                   abort_no_stack if @stack.nil?
                   stack_details = parse_response(token.get("#{base_url}/stacks/#{@stack}.json"))
                   stack_name = stack_details['response']['name']
                   say stack_name+": "
                   response = token.post("#{base_url}/stacks/#{@stack}/redeploy.json", {})
                   say JSON.parse(response.body)['response']['message']
                rescue OAuth2::Error => e
                    error_message(e)
                end
            end

            desc "save", "Save the given stack information in the current directory"
            option :stack, :aliases => "-s", :required => true
            option :alias, :aliases => "-a", :required => false
            def save
                before_each_action
                begin
                    stack_details = parse_response(token.get("#{base_url}/stacks/#{options[:stack]}.json"))
                    stack_name = stack_details['response']['name']
                    if !File.directory?(stack_path)
                        Dir.mkdir(stack_path)
                    end
                    @stack_json = { :stack_id => options[:stack], :stack_name => stack_name}
                    if (!FORBIDDEN_STACKS_ALIAS.include? options[:alias])
                        File.open(stack_file(options[:alias]),"w") do |f|
                            f.write(@stack_json.to_json)
                        end
                    else
                        abort 'Stack alias "'+options[:alias]+'" is forbidden, please retry with another alias.'
                    end
                    @stack = options[:stack]

                    say "Linked stack #{stack_name} to #{stack_file(options[:alias])}.\n"
                    if !options[:alias]                
                        say "You are now able to use other commands without specify the stack UID."
                    else 
                        say "You are now able to use other commands and specific this stack's alias, like so: "\
                        "`c66 deploy -s #{options[:alias]}`"
                    end 
                rescue OAuth2::Error => e
                    error_message(e)
                end
            end

            desc "info", "#{CLIENT_FULLNAME} information"
            def info
                before_each_action
                begin
                    say "#{CLIENT_FULLNAME} version #{C66::Utils::VERSION}\n\n"
                    Dir.glob("#{stack_path}/*.json") do |stack_file|
                        stack_alias = File.basename(stack_file, ".json")
                        if (!FORBIDDEN_STACKS_ALIAS.include? stack_alias)
                            load_stack(stack_alias)
                            if stack_alias == "stack" 
                                say "Default stack: no alias"
                            else
                                say "Alias: #{stack_alias}"
                            end
                            stack_details = parse_response(token.get("#{base_url}/stacks/#{@stack}.json"))
                            say "Name: #{stack_details['response']['name']}"
                            say "UID: #{stack_details['response']['uid']}"
                            say "Environment: #{stack_details['response']['environment']}"
                            say "Status: #{STATUS[stack_details['response']['status']]}\n\n"
                        end
                    end
                rescue OAuth2::Error => e  
                    puts "Didn't find any valid stack, please use the 'save' method."               
                    error_message(e)
                end
            end

            desc "lease", "Allow an IP address to connect temporary to the specific stack through ssh (22)"
            option :stack, :aliases => "-s", :required => false
            option :ip_address, :aliases => "-i", :required => false
            option :time_to_open, :aliases => "-t", :required => false, :default => 20
            def lease()
                before_each_action
                begin
                    abort "time_to_open value is invalid. The value must be an integer between 0 and 240 (~4 hours)." if !(0..240).include? options[:time_to_open].to_i
                    get_stack(options[:stack])
                    abort_no_stack if @stack.nil?
                    stack_details = parse_response(token.get("#{base_url}/stacks/#{@stack}.json"))
                    stack_name = stack_details['response']['name']
                    response = token.post("#{base_url}/stacks/#{@stack}/lease.json", { :body => { :ip_address => options[:ip_address], :time_to_open => options[:time_to_open] }})
                    say JSON.parse(response.body)['response']['message'] if JSON.parse(response.body)['response']['ok']
                rescue OAuth2::Error => e
                    error_message(e)
                end
            end
        end
    end
end
