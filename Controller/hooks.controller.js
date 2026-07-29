import { asyncHandler } from "../Helpers/asyncHandler.helpers.js";
import { User } from "../Models/user.models.js"
import { Features } from "../Models/inAppFeatures.models.js";

export const setHooks = asyncHandler(async(req,res)=>{
    const {hook_name,hook_value,hook_description} = req.body;
    const user = req.user;

    if(!user){
        return res.status(404).json({
            messege:"You are Not Authorized or Try Refreshing..."
        })
    }

    if(!hook_name || !hook_description || !hook_value){
        return res.status(400).json({messege:"Please Enter all Hook Details"})
    }

    let featuresDoc = await Features.findById(user.featuresAccess);

    if(!featuresDoc){
        featuresDoc = await Features.findOne({ user: user._id });
    }

    if(!featuresDoc){
        featuresDoc = await Features.create({
            user: user._id,
            hooks: [{ hook_name, hook_value, hook_description }]
        });

        await User.findByIdAndUpdate(user._id, {
            featuresAccess: featuresDoc._id
        });
    } else {
        featuresDoc.hooks.push({ hook_name, hook_value, hook_description });
        await featuresDoc.save();
    }

    return res.status(201).json({
        messege:"Hook Created Successfully",
        hooks: featuresDoc.hooks
    })
})

export const viewHooks = asyncHandler(async(req,res)=>{
    const user = req.user;
    if(!user){
        return res.status(404).json({
            messege:"You are Not Authorized or Try Refreshing..."
        })
    }
    const hooksDoc = await Features.findOne({ user: user._id });

    if(!hooksDoc){
        return res.status(201).json({
            messege:"No hooks found for this user"
        })
    }

    return res.status(201).json({
        messege:"Hooks Registered by User",
        hooks:hooksDoc.hooks
    })
})

export const deleteHooks = asyncHandler(async(req,res)=>{
    const user = req.user;
    if(!user){
        return res.status(404).json({
            messege:"You are Not Authorized or Try Refreshing..."
        })
    }
    const {deleteHookName} = req.body;

    if(!deleteHookName){
        return res.status(400).json({
            messege:"Please provide hook name to delete"
        })
    }

    const hooksDoc = await Features.findOneAndUpdate(
        { user: user._id },
        { $pull: { hooks: { hook_name: deleteHookName } } },
        { new: true }
    )

    if(!hooksDoc){
        return res.status(404).json({
            messege:"No features document found for this user"
        })
    }

    return res.status(200).json({
        messege:"Hook deleted successfully",
        hooks:hooksDoc.hooks
    })
})