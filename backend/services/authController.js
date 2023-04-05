import db from './db.js';
import jwt from 'jsonwebtoken';
import { nanoid } from 'nanoid';
import config from '../config.js';
import utils from './utils.js'

async function getUsers(req, res) {
    db.query("SELECT username,email,connectedID,createdAt,lastLoad,lastSave FROM user", (err, result) => {
        console.log(result);
        res.json({message:"success",data:result});
    });
}

async function getUserData(req, res) {
    var userid = req.decoded['userID']
    if (userid == null) {
        res.status(403).json({ message: "incomplete parameter" });
        return
    }
    db.query("SELECT username,email,stats,connectedID,createdAt,lastLoad,lastSave FROM user WHERE uid=?"[uid], (err, result) => {
        if(err)
            res.json({message:err});
        res.json({message:"success",data:result[0]});
    });
}

async function login(req, res) {
    console.log("Received login request : " );
    var data = req.body;
    var username = data.username;
    if (username == null || data.password == null) {
        res.status(403).json({ message: "incomplete parameter" });
    }
    var password = utils.HashPassword(data.password);
    db.query("SELECT uid,password FROM user WHERE username=?;", [username], (err, result) => {
        if(err){
            console.log(err)
            res.status(403).json({message:err});
            return;
        }
        if (result == null || result.length == 0) {
            res.status(403).json({ message: "account is not exist" });
            console.log("Account is not exist");
            return;
        }
        if (result[0]['password'] != password) {
            res.status(403).json({ message: "incorrect password" });
            console.log("Incorrect password");
            return;
        }
        var uid = result[0]['uid'];
        //give player a token for further credential
        let token = jwt.sign({ userID: uid, loginID: loginID }, config.key, { expiresIn: config.expireTime });
        res.json({ message: "success", token: token, uid: uid });
        loginID += 1;
        console.log("Login success");
    });
}

async function register(req, res) {
    console.log("Received register request : ");
    var data = req.body;
    var uid = nanoid();
    var username = data.username;
    var email = data.email;
    var password = utils.HashPassword(data.password);
    console.log(password)
    db.query("SELECT uid FROM user WHERE username = ? OR email = ?;", [username, email], (err, result) => {
        if (result == null || result.length > 0) {
            res.status(403).json({ message: "Email or username is already exist" });
            return;
        }
        db.query("INSERT INTO user (uid, username, email ,password) VALUES (?, ?, ?, ?);", [uid, username, email, password], (err, result) => {
            if (result == null) {
                res.status(403).json({ message: "failed" });
                console.log("Register failed");
                return;
            }
            //give player a token for further credential
            let token = jwt.sign({ userID: uid, loginID: loginID }, config.key, { expiresIn: config.expireTime });
            res.json({ message: "success", token: token, uid: uid });
            loginID += 1;
            console.log("Register success");
        });
    });
}

async function checkToken(req, res) {
    console.log("Received " + req.body);
    var userid = req.decoded['userID'];
    console.log("Token read as " + req.decoded['userID']);
    db.query("SELECT username FROM user WHERE uid=?",[userid], (err, result) => {
        if(err) {
            res.status(403).send(err);
            return;
        }
        res.send(result[0].username);
    });
}

export default { getUsers, login, register, checkToken,getUserData }
