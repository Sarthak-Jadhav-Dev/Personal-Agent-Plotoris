import 'dotenv/config'; 
import { dbConnect } from "./DB/db.js";
import { app } from "./app.js";
import "./Controller/appWakup.controller.js";

dbConnect()
.then(app.listen(process.env.PORT || 8000,()=>{
    console.log("App Running Successfully");
}))
.catch((error)=>{
    console.log("App Crashed... Due to : ",error)
})