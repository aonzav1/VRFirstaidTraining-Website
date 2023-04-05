import db from './db.js';
import jwt from 'jsonwebtoken';
import { nanoid } from 'nanoid';
import config from '../config.js';
import utils from './utils.js'
import bodyParser from 'body-parser';

var perPage = 10;


async function getScenarios(req, res) {
    var page = req.query.page;
    var addtionalQuery = req.query.query;
    if(addtionalQuery == null)
        addtionalQuery = "";
    if (page == null)
        page = 0;
    var min = page * perPage;
    var queryString = 'SELECT scenarioId,name, description, location, difficulty, thumbnail, lastUpdated FROM scenario '+addtionalQuery+' ORDER BY scenarioId LIMIT '+perPage+' OFFSET '+min;
    db.query(queryString , (err, result) => {
        res.json({ message: "success", data: result });
    });
}

async function getScenarioByUser(req, res) {
    var userid = req.decoded['userID']
    var page = req.query.page;
    if (page == null)
        page = 0;
    var min = page * perPage;
    console.log("Find scenario created by "+userid);
    var queryString = 'SELECT scenarioId,name, description, location, thumbnail, difficulty, lastUpdated FROM scenario WHERE createdBy=? ORDER BY scenarioId LIMIT ? OFFSET ?';
    db.query(queryString, [userid,perPage,min], (err, result) => {
        console.log(err);
        console.log(result);
        res.json({ message: "success", data: result });
    });
}

async function getScenarioData(req, res) {
    //var userid = req.decoded['userID']
    var scenario_id = req.query.id
    if (scenario_id == null) {
        res.status(403).json({ message: "incomplete parameter" });
        return
    }
    db.query("SELECT * FROM scenario WHERE scenarioId=?", [scenario_id], (err, result) => {
        if (err)
            res.json({ message: err });
        res.json(result[0]);
    });
}

async function addScenario(req, res) {
    var userid = req.decoded['userID']
    console.log("Add Scenario requested");
    var data = req.body
    if (data == null) {
        res.status(403).json({ message: "incomplete parameter" });
        return
    }
    //assign uid
    var scenario_query = 'INSERT INTO scenario SET createdBy=?, name=?, description=?,\n\
    difficulty=?, introduction=?, location=?, thumbnail=?,patients=?, items=?,timeLimit=?,timeScoreMult=?,\n\
    interactMult=?,endOnDeath=?,endOnWrong=?,penaltyScoreMult=?,bonusScoreMult=?,allowTablet=?,\n\
    showGuide=?,showStatus=?,passScore=?,goldBadgeScore=?,lastUpdated=?'

    console.log(data.name);

    db.query(scenario_query, [
        userid,
        data.name,
        data.description,
        data.difficulty,
        data.introduction,
        data.location,
        data.thumbnail,
        JSON.stringify(data.patients),
        JSON.stringify(data.items),
        data.timeLimit,
        data.timeScoreMult,
        data.interactMult,
        data.endOnDeath,
        data.endOnWrong,
        data.bonusScoreMult,
        data.allowTablet,
        data.showGuide,
        data.showStatus,
        data.patientScoreMult,
        data.passScore,
        data.goldBadgeScore,
        new Date().toISOString().slice(0, 19).replace('T', ' ')], (err, result) => {
            if (err){
                console.log(err)
                res.json({ message: err });
            }
            res.json({ message: "success"});
        });
}


async function editScenario(req, res) {
    //var userid = req.decoded['userID']
    /* var scenario_id = req.query.id
     if (scenario_id == null) {
         res.status(403).json({ message: "incomplete parameter" });
         return
     }
     //Check if user is owner
     db.query("UPDATE scenario SET  WHERE scenarioId=?", [scenario_id], (err, result) => {
         if (err)
             res.json({ message: err });
         res.json({ message: "success", data: result[0] });
     });*/
}


async function deleteScenario(req, res) {
    //var userid = req.decoded['userID']
    var scenario_id = req.query.id
    if (scenario_id == null) {
        res.status(403).json({ message: "incomplete parameter" });
        return
    }
    //Check if user is owner
    db.query("DELETE FROM scenario WHERE scenarioId=?", [scenario_id], (err, result) => {
        if (err)
            res.json({ message: err });
        res.json({ message: "success", data: result[0] });
    });
}

export default { getScenarios,getScenarioByUser, getScenarioData, addScenario, editScenario, deleteScenario }
