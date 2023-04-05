import config from './config.js';
import jwt from 'jsonwebtoken';

let checkToken = (req,res,next) => {
	let token = req.headers["authorization"];
	if(token){
		jwt.verify(token,config.key,(err,decoded)=>{
			if(err)
			{
                return res.status(403).send("Invalid token");
			}else{
				req.decoded = decoded;
				next();
			}
		})	
	}else{
		return res.status(403).send("Token is not provided");
	}
}

export default {
	checkToken: checkToken,
};