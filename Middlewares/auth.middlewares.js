import { asyncHandler } from "../Helpers/asyncHandler.helpers.js"
import jwt from "jsonwebtoken"
import {User} from "../Models/user.models.js"

export const verifyJWT = asyncHandler(async(req,res,next)=>{
    const token = req.cookies.token || req.headers("Authorization");
    if(!token){
        return res.status(401).json({error:"Access denied. No token provided."})
    }
    const decodedToken = jwt.verify(token,process.env.JWT_ACCESS_SECRET);
    const user = await User.findById(decodedToken);
    if(!user){
        return res.status(401).json({error:"User not found"})
    }
    req.user = user;
    next();
})