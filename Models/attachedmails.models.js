import mongoose from "mongoose";

const attachedMailsSchema = new mongoose.Schema({
    mails:[
        {
            email:{
                type:String,
                required:true,
                unique:true,
            },
            isValidated:{
                type:Boolean,
                default:false,
                required:true,
            },
            attachedUser:{
                type:mongoose.Schema.Types.ObjectId,
                ref:"User",
                required:true,
            }
        },
    ]
},{timestamps:true});

export const AttachedMail = mongoose.model("AttachedMail",attachedMailsSchema);