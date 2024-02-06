const { MongoClient, ServerApiVersion } = require("mongodb");
// Replace the placeholder with your Atlas connection string
//input connectionString
//input user
//input location
//input age
//input userType
//input realName
const uri = connectionString;
const userName = user;
const loc = location;
const type = userType;
const real = realName;
const userAge = age;
// Create a MongoClient with a MongoClientOptions object to set the Stable API version
const client = new MongoClient(uri,  {
        serverApi: {
            version: ServerApiVersion.v1,
            strict: true,
            deprecationErrors: true,
        }
    }
);
async function insertUser() {
  try {
    // Connect the client to the server (optional starting in v4.7)
    await client.connect();
    // Send a ping to confirm a successful connection
    const userDB = client.db("users");
    await userDB.command({ ping: 1 });
    console.log("Pinged deployment. Successfully connected to MongoDB!");

    // insert user values across multiple collections, give permissions to user
    var myObj = { name: user, realName: realName, age: age, location: location };
    await userDB.collection("userList").insertOne(myObj, function(err, res) {
      if (err) throw err;
      console.log("1 document inserted into collection userList");
    });


    myObj = { user: user, userType: userType, active: "True"};
    await userDB.collection("permissionList").insertOne(myObj, function(err, res) {
      if (err) throw err;
      console.log("1 document inserted into collection permissionList");
    });


    const updateDB = client.db("orders");
    var commandDoc;
    if(userType == "admin"){
      commandDoc = {
        grantRolesToUser: user,
        roles: [ "readWrite" ],
        writeConcern: { w: "majority" }
      };
    }else{
      commandDoc = {
        grantRolesToUser: user,
        roles: [ "read" ],
        writeConcern: { w: "majority" }
      };
    }
    const result = await updateDB.command(commandDoc);
    

  } finally {
    // Ensures that the client will close when you finish/error
    await client.close();
  }
}
insertUser().catch(console.dir);