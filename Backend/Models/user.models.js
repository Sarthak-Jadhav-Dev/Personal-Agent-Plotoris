import mongoose from "mongoose";
import jwt from "jsonwebtoken"
const userSchema = new mongoose.Schema({
    username: {
        type: String,
        required: true,
        unique: true
    },
    fullname: {
        type: String,
        required: true
    },
    email: {
        type: String,
        required: true,
        unique: true
    },
    refreshToken:{
        type:String,
    },
    googleRefreshToken:{
        type:String,
    },
    googleId:{
        type:String,
        unique:true,
    },
    authType:{
        type:String,
        enum:["Local","Google"],
        default:"Local",
    },
    featuresAccess:{
        type:mongoose.Schema.Types.ObjectId,
        ref:"Features",
        default:null,
        index:true
    }
}, { timestamps: true })

userSchema.methods.generateAccessToken = function(){
    return jwt.sign(
        {
            _id:this._id,
            googleToken:this.googleRefreshToken,
            username:this.username,
            email:this.email

        },
        process.env.JWT_ACCESS_SECRET,
        {
            expiresIn:process.env.JWT_ACCESS_EXPIRY
        }
    )
}
userSchema.methods.generateRefreshToken = function(){
    return jwt.sign(
        {
            _id:this._id
        },
        process.env.JWT_REFRESH_SECRET,
        {
            expiresIn:process.env.JWT_REFRESH_EXPIRY
        }
    )
}

export const User = mongoose.model("User", userSchema);