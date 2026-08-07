import mongoose from "mongoose";

export async function dbConnect(){
    try {
        await mongoose.connect(process.env.MONGO_URI);
        console.log("DB Connected Successfully")
    } catch (error) {
        console.error("DB Not Connected ",error);
        process.exit(1);
    }
}