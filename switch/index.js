require('dotenv').config()

const express = require("express");
var morgan = require('morgan');
var request = require('request');


const PROC_PORT = process.env.PROC_PORT || 80;

const API_PREFIX = process.env.API_PREFIX || "/api";
const API_ENDPOINT = process.env.API_ENDPOINT || "http://shelly-pdu-backend:5000";

const FRONTEND_ENDPOINT = process.env.FRONTEND_ENDPOINT || "http://shelly-pdu-frontend";


const router = express.Router();

router.use(API_PREFIX, (req, res, next) => {
    console.log("Serving from API endpoint: " + API_ENDPOINT + req.url)
    return request(API_ENDPOINT + req.url).pipe(res)
});

router.use("/", (req, res, next) => {
    console.log("Serving from frontend: " + API_ENDPOINT + req.url)
    return request(FRONTEND_ENDPOINT + req.url).pipe(res)
});


const app = express();
app.use(morgan('dev'))
app.use("/", router);

app.listen(PROC_PORT, () => {
    console.info(`Listening on port ${PROC_PORT}`);
});