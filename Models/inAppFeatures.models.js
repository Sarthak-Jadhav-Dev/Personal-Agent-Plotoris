import mongoose from "mongoose";

const featuresScheme = new mongoose.Schema({
    user:{
        type:mongoose.Schema.Types.ObjectId,
        ref:"User",
        required:true,
        unique:true,
        index:true
    },
    hooks:[
        {
            hook_name:{
                type:String,
                required:true,
                trim:true
            },
            hook_value:{
                type:String,
                required:true,
            },
            hook_description:{
                type:String,
                required:true,
            },
        },
    ]
},{timestamps:true});

export const Features = mongoose.model("Features",featuresScheme);