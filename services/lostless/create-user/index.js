import express from 'express';
import bodyParser from 'body-parser';
import path from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';
import dotenv from 'dotenv';
import { handlers } from './api/handlers.js';

dotenv.config();

// Fix for __dirname in ES modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const app = express();
const PORT = 3000;
const apiRouter = express.Router();

app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());
app.use(express.static(path.join(__dirname, 'public')));

app.get('/generate', (_req, res) => {
  res.sendFile(path.join(__dirname, 'views', 'generate-invite.html'));
});

app.get('/welcome/:discInvite', (_req, res) => {
  res.sendFile(path.join(__dirname, 'views', 'welcome.html'));
});

app.get('/invite/:token', (_req, res) => {
  res.sendFile(path.join(__dirname, 'views', 'create-account.html'));
});

apiRouter.post('/create-account', handlers.createAccount);
apiRouter.post('/generate-invite', handlers.generateInvite);
apiRouter.get('/validate-invite/:token', handlers.validateInvite);

app.use('/api', apiRouter);

app.listen(PORT, () => {
  console.log(`Listening on http://localhost:${PORT}`);
});
