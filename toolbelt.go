package main

import "fmt"
import "code.google.com/p/goauth2/oauth"
import "log"
import "encoding/json"
import "io/ioutil"
import "flag"

// 5d9194b2a080d353ab2b8324d742933d9627f46c192be964a7527659caa15abf
var (
	baseURL = "https://www.cloud66.com/api/2"
	clientId = "638412995ee3da6f67e24564ac297f9554ee253a8fe1502348c4d6e845bd9d0d"
	clientSecret = "961398353aa6e7f0f36dfcd83e447d748c54481b7a3b143e0119441516e8b91f"
	scope = "public redeploy"
	redirectURL = "urn:ietf:wg:oauth:2.0:oob"
	authURL = "https://www.cloud66.com/oauth/authorize"
	tokenURL = "https://www.cloud66.com/oauth/token"
	cachefile = flag.String("cache", "/tmp/c66_toolbelt.json", "Token cache file")
	code = flag.String("code", "", "Authorization Code")
	stackUid = flag.String("stack", "", "Stack Uid")
	statusDics = make(map[int]string)
)

func main() {
	setup()
	// get the command
	command := flag.String("command", "", "Command to run")
	
	flag.Parse()
	
	switch *command {
		case "deploy": deploy()
		case "init": initialize()
		case "stacks" : listStacks()
		default: fmt.Println("unknown command")
	}
}

func deploy() {
	transport := initialize()
	requestURL := baseURL + "/stacks/" + *stackUid + "/redeploy.json"
	
	r, err := transport.Client().Post(requestURL, "application/json", nil)
	if err != nil {
		log.Fatal("Get:", err)
	}
	defer r.Body.Close()
	result, _ := ioutil.ReadAll(r.Body)
	fmt.Println(string(result))
}

type Result struct {
	Stacks []Stack `json:"response"`
}

type Stack struct {
	Uid string`json:"uid"`
	Name string `json:"name"`
	Status int `json:"status"`
}

func setup() {
	statusDics[0] =	"Pending analysis"
	statusDics[1] =	"Deployed successfully"
	statusDics[2] =	"Deployment failed"
	statusDics[3] =	"Analyzing"
	statusDics[4] =	"Analyzed"
	statusDics[5] =	"Queued for deployment"
	statusDics[6] =	"Deploying"
	statusDics[7] =	"Unable to analyze"
}

func listStacks() {
	transport := initialize()
	requestURL := baseURL + "/stacks.json"

	r, err := transport.Client().Get(requestURL)
	if err != nil {
		log.Fatal("Get:", err)
	}
	defer r.Body.Close()
	result, _ := ioutil.ReadAll(r.Body)
	
	var response Result
	if err := json.Unmarshal(result, &response); err != nil {
		panic(err)
	} else {
		for i := 0; i < len(response.Stacks); i++ {
			stack := response.Stacks[i]
			fmt.Printf("%v (%v) - %s\n", stack.Name, stack.Uid, statusDics[stack.Status])
		}
	}
}

func initialize() (*oauth.Transport){
	config := &oauth.Config{
		ClientId:     clientId,
		ClientSecret: clientSecret,
		RedirectURL:  redirectURL,
		Scope:        scope,
		AuthURL:      authURL,
		TokenURL:     tokenURL,
		TokenCache:   oauth.CacheFile(*cachefile),
	}
	transport := &oauth.Transport{Config: config}
	token, err := config.TokenCache.Token()
	if err != nil {
		if *code == "" {
			url := config.AuthCodeURL("")
			fmt.Println("Visit this URL to get a code, then run again with -code=YOUR_CODE\n")
			fmt.Println(url)
			return nil
		}
		token, err = transport.Exchange(*code)
		if err != nil {
			log.Fatal("Exchange:", err)
		}
		fmt.Printf("Token is cached in %v\n", config.TokenCache)
	}
	
	transport.Token = token
	
	return transport
}
