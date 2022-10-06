# 🔑 gmod-web-api-auth

Or short: **GWAA**

This combination of a Garry's Mod Addon and a Node.js Fastify REST-API allows you to authenticate a Garry's Mod player to allow making authenticated requests your own REST-APIs, without the player ever noticing it (Except the improved performance!).

**This project is intended for developers, see more in the "Use cases" paragraph.**

### 📙 How does it work?
1. The player joins a Garry's Mod server
2. The Garry's Mod server makes a requests to the API
3. The API generates and returns a [JWT](https://jwt.io/) associated to the player
4. The returned [JWT](https://jwt.io/) is networked to the player and stored clientside in memory
5. The client is now able to make authenticated requests to other APIs
6. Other APIs can easily confirm the validity of the session by validating the [JWT](https://jwt.io/)

### ✨ Use cases
The intended use case is to receive and send large amounts of data from / with a REST-API instead of pushing it through the Garry's Mod network channel. Examples for this would be images and large JSON payloads which would otherwise even need to be split into several parts in some cases because of the 64kb net message size limit. In general, a web server can easily respond to **way** more requests than the Garry's Mod network channel.

This project is most useful to developers who create Garry's Mod addons and want to handle large amounts of data. It will not fix any existing addons or anything like that. The use case may be quite small, but it still is quite an interesting way of offloading the server, in my opinion.

### ⚡ Quick start
1. Download & extract `gwaa-gmod-addon.zip` and `gwaa-nodejs-app.zip` from the [latest release](https://github.com/luca1197/gmod-web-api-auth/releases).
2. Run `npm install` (If using npm) in the Node.js app directory
3. Configure the `sv_config_gmod_web_api_auth.lua` file in the Garry's Mod addon and the `.env` & `config.json` files in the Node.js app according to [this Wiki page](https://github.com/luca1197/gmod-web-api-auth/wiki/Configuration).
4. Move the Garry's Mod addon into your servers `addons` folder and restart the server. Start the API server.
5. Connect to the Garry's Mod server and check your client & server console. You should see a message that says that the session was successfully initialized.

If you do not have your own REST-API to use this project for already, you can just extend the one provided by this project to save a lot of time and effort! Take a look at [the Wiki page](https://github.com/luca1197/gmod-web-api-auth/wiki/Adding-your-own-routes-to-the-API) to learn how.

After you followed the steps above, you can use it like this in Garry's Mod:
```lua
-- CLIENTSIDE
-- This hook will be called when the user is authenticated for the first time which
-- is less than a second after clientside InitPostEntity in most cases.
-- To make authenticated requests elsewhere, do the same as below but replace the
-- authorization headers value with GWAA.GetSession() to get the currently valid JWT
hook.Add("GWAA:InitialAuthenticated", "GWAA:Example", function(jwt)

  http.Fetch("api.example.com/exampleroute", function(body, size, headers, code)
    print("Request success! Data:", body)
  end, function(err)
    print("Request failed! Error:", err)
  end, {
    ["authorization"] = jwt -- How you authenticate requests on your API may be completely different
  })

end)
```

And this is how your own API route **could** look like (The example below is using Fastify).
```js
// ... Initiate Fastify and do other stuff ...

import jsonwebtoken from "jsonwebtoken"

fastify.route({
  method: "GET",
  url: "exampleroute",
  handler: (req, res) => {
  
    // Return data, e.g. query a database or do something else
    
    return {
      ok: true,
      message: `Hello World! You SteamID is ${req.decoded.steamid}`
    }
    
  },
  preValidation: (req, res, done) => {
  
    // In this example, we verify the JWT locally, you can also use the /verify route of the projects API,
    // but verifying locally is usually the better way. Ideally, you would not add this big preValidation
    // to every route in production, but instead define a function that does all of this for example.
    
    if (!req.headers.authorization) {
      return res.status(403).send({ok: false, message: 'Missing authorization header'})
    }
    
    const decoded = await new Promise(resolve => {
      jsonwebtoken.verify(req.headers.authorization, 'YOUR SECRET, SAME AS SET IN .env OF PROJECT API', (err, decoded) => {
        if (err) {
          resolve({success: false})
        } else {
          resolve({success: true, decoded: decoded})
        }
      })
    })
    
    if (!decoded || !decoded.success) {
      return res.status(403).send({ok: false, message: 'Invalid or expired JWT'})
    }
    
    // To use the decoded JWT in the request handler function above, add it to the req object
    req.DecodedJWT = decoded.decoded
    
    done()
    
  },
})
```

### 📜 Documentation
For more details, take a look at [the Wiki of this repository](https://github.com/luca1197/gmod-web-api-auth/wiki).

### 🤔 FAQ
**Q:** Do I need to host the API myself?<br>
**A:** Yes.

**Q:** Can I add my own data to the JWT (e.g. user ranks, permissions)?<br>
**A:** In theory this would be a simple addition, but I did not add that by design because then revokability would become a very important topic which would destroy the advantages of JWTs and require a database, making the setup and authentication way more complex. To still give responses depending on the users permissions on your Garry's Mod server, you could connect to its database and query the ranks by their SteamID.

### ⚖️ License
[MIT License](https://github.com/luca1197/gmod-web-api-auth/blob/main/LICENSE) - Have fun!
