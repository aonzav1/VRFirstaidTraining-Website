import express from 'express';
const app = express();
import bodyParser from 'body-parser';
import multer from 'multer';
import path, { dirname } from "path";
import { fileURLToPath } from 'url';
import middleware from './middleware.js';
import cors from "cors";

import authController from './services/authController.js';
import scenarioController from './services/scenarioController.js';

app.use(cors({
	"origin": "*",
	"methods": "GET,HEAD,PUT,PATCH,POST,DELETE",
}));
const port = process.env.PORT || 13000;

const storage = multer.diskStorage({
	destination: function (req, file, callback) {
		callback(null, './uploads')
	},
	filename: function (req, file, callback) {
		callback(null, file.originalname.substring(0, file.originalname.length - 4) + "," + Date.now().toString()+".png")
	},
})

const upload = multer({ storage })

global.dateID = "";
global.loginID = 0;

const __filename = fileURLToPath(import.meta.url);

const __dirname = path.dirname(__filename);
app.use('/',express.static(__dirname + '/uploads'));

app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: true }))

/************************/
//---------APIs-----------
/************************/

//Authentication
app.get('/users', authController.getUsers)
app.post('/login', authController.login);
app.post('/register', authController.register);
app.post('/checkToken', middleware.checkToken, authController.checkToken);

//Users
//save stats
app.get('/getUserData', middleware.checkToken, authController.getUserData);

//Scenario data
app.get('/scenarios', scenarioController.getScenarios);
app.get('/scenario/detail', scenarioController.getScenarioData);
app.get('/scenario/user', middleware.checkToken, scenarioController.getScenarioByUser);
app.post('/scenario/add', middleware.checkToken, scenarioController.addScenario);
app.put('/scenario/edit', middleware.checkToken, scenarioController.editScenario);
app.delete('/scenario/delete', middleware.checkToken, scenarioController.deleteScenario);

app.post('/upload', upload.single('image'), (req, res) => {
	res.send(req.file)
})

//Rate scenario

//Storage
//Upload image
//Upload save file
//Check for syncing
//Request data to sync

//Testing
//app.get('/', (req, res) => { res.send("Connected successfully") });
app.get('/error', async (req, res) => {
	console.log("Test error");
	res.status(403).send("Test error");
});
app.get('/testjson', async (req, res) => {
	console.log("Testjson");
	res.json({ userID: 11, username: "Amazing", loginID: loginID });
});
app.post('/sendjson', async (req, res) => {
	console.log("Received " + req.body);
	res.send("Success");
});


app.listen(port, () => {
	console.log(`Server running at ${port}`);
});




