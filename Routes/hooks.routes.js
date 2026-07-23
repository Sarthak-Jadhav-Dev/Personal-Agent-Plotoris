import { Router } from "express";
import {setHooks,viewHooks,deleteHooks} from "../Controller/hooks.controller.js"
import {verifyJWT} from "../Middlewares/auth.middlewares.js"

const hooksRouter = Router();

hooksRouter.route("/api/hooks/setHook").put(verifyJWT,setHooks);
hooksRouter.route("/api/hooks/getHooks").get(verifyJWT,viewHooks);
hooksRouter.route("/api/hooks/deleteHook").delete(verifyJWT,deleteHooks)

export default hooksRouter;