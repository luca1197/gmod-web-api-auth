-- URL / IP of the API server
-- Keep the note about destinations on private networks on this Wiki page in mind: https://wiki.facepunch.com/gmod/http.Fetch
GWAA.APIServerURL = "example.com"

-- API key for authenticating requests to the GWAA API server
-- If you do not want to store the API key here, set the value below to "data-file", create a file in the data folder called "gwaa_api_key.txt" and store the key in there.
-- The global variable below will not be accessible after the addon is fully loaded. This does NOT guarantee that you API key is completely safe.
GWAA.APIKey = "example-key"