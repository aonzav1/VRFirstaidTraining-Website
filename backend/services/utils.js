import CryptoJS from 'crypto-js';


function HashPassword(password){
    let digest = "somedigestword"
    let salt = password
    let algo = CryptoJS.algo.SHA256.create()
    algo.update(digest, "utf-8")
    algo.update(CryptoJS.SHA256(salt), "utf-8")
    return algo.finalize().toString(CryptoJS.enc.hex)
}

export default  {HashPassword}