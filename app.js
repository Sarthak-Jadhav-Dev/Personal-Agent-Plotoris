import express from "express"
import cors from "cors"
import cookieParser from "cookie-parser"
import authRouter from "./Routes/auth.routes.js"
import hooksRouter from "./Routes/hooks.routes.js";

const app = express();

app.use(express.json())
app.use(cors())
app.use(cookieParser())

// Auth Routes
app.use("/api/auth", authRouter)

// Hooks Routes
app.use("/api/hooks",hooksRouter)


export {app};