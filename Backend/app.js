import express from "express"
import cors from "cors"
import cookieParser from "cookie-parser"
import authRouter from "./Routes/auth.routes.js"
import hooksRouter from "./Routes/hooks.routes.js";
import mailRouter from "./Routes/mails.routes.js";
import analysisRouter from "./Routes/analysis.routes.js";

const app = express();

app.use(express.json())
app.use(cors())
app.use(cookieParser())

// Auth Routes
app.use("/api/auth", authRouter)

// Hooks Routes
app.use("/api/hooks",hooksRouter)

//Mails Routes
app.use("/api/mails",mailRouter)

//Analysis Routes
app.use("/api/analysis",analysisRouter)


export {app};