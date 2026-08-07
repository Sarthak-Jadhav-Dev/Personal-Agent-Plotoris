import { asyncHandler } from "../Helpers/asyncHandler.helpers.js"
import jwt from "jsonwebtoken"
import {User} from "../Models/user.models.js"

export const verifyJWT = asyncHandler(async(req,res,next)=>{
    const cookieToken = req.cookies?.token || req.cookies?.accessToken;
    const authHeader = req.header("Authorization");
    const token = cookieToken || (authHeader?.startsWith("Bearer ") ? authHeader.split(" ")[1] : authHeader);

    if(!token){
        return res.status(401).json({error:"Access denied. No token provided."})
    }

    const decodedToken = jwt.verify(token, process.env.JWT_ACCESS_SECRET);
    const userId = decodedToken?._id || decodedToken?.id;
    const user = await User.findById(userId);

    if(!user){
        return res.status(401).json({error:"User not found"})
    }

    req.user = user;
    next();
})